//
//  SongPersistancyManager.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MobileCoreServices
import AVFoundation
import CoreData
import UIKit

class SongPersistancyManager: PersistanceController {
    
    static let sharedInstance = SongPersistancyManager()
    
    func getSongArray(playlist: PlaylistEntity,
                      cntx: NSManagedObjectContext? = nil) -> [SongEntity] {
        let cntx = cntx ?? self.managedObjectContext!
        return fetchData(entityName: "SongEntity",
                         sortIn: NSSortDescriptor(key: "songOrder", ascending: true),
                         predicate: NSPredicate(format: "%K == %@", "playlist.playlistName", playlist.playlistName!),
                         cntx: cntx) as! [SongEntity]
    }
    
    func getSongPath(song: SongEntity) -> URL {
        let playlistName = song.playlist?.playlistName
        let songName = song.songName
        return docsUrl.appendingPathComponent(playlistName!).appendingPathComponent(songName!)
    }
    
    func moveSong(toMove: SongEntity, fromPlaylist: PlaylistEntity, toPlaylist: PlaylistEntity) {
        let fromPlaylist = toMove.playlist
        let toPath = PlaylistPersistancyManager.sharedInstance.getPlaylistPath(playlist: toPlaylist).appendingPathComponent(toMove.songName!)
        do {
            try fm.moveItem(at: getSongPath(song: toMove), to: toPath)
            fromPlaylist!.removeFromSongs(toMove)
            toPlaylist.addToSongs(toMove)
        }
        catch let error as NSError {
            log.error("Could not move song to a different playlist: \(error)")
        }
    }
    
    func populateSongs(forPlaylist: PlaylistEntity,
                       cntx: NSManagedObjectContext? = nil) -> [SongEntity] {
        let cntx = cntx ?? self.managedObjectContext!
        let playlistName = forPlaylist.playlistName!
        var songsArray = getSongArray(playlist: forPlaylist, cntx: cntx)
        var toMatchWithAudioFiles = songsArray
        //That's how fm and docsUrl are initialized
        //fm = FileManager.default
        //docsUrl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        //playlistName is a directory
        let playlistUrl: URL = docsUrl.appendingPathComponent(playlistName) //Inside playlist dir
        let contentsArray = try! fm.contentsOfDirectory(at: playlistUrl,
                                                        includingPropertiesForKeys: nil)
        contentsArray.forEach {
            entry in
            let fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, entry.pathExtension as CFString, nil)?.takeRetainedValue()
            let ifAudio = UTTypeConformsTo(fileUTI!, kUTTypeAudio)
            if ifAudio {
                let index = toMatchWithAudioFiles.index(where: {el in el.songName == entry.lastPathComponent })
                if index == nil {
                    let song = SongEntity(context: cntx)
                    song.songName = entry.lastPathComponent
                    song.songOrder = -1
                    song.isProcessed = false
                    forPlaylist.addToSongs(song)
                    songsArray.append(song)
                } else {
                    //Remove songs to find unlinked one
                    toMatchWithAudioFiles.remove(at: index!)
                }
            }
        }
        if !toMatchWithAudioFiles.isEmpty {
            //There are songs w/o corresponding audio file
            //Probably was removed manually
            for redundantSongEntity in toMatchWithAudioFiles {
                if let index = songsArray.index(where: {el in el == redundantSongEntity}) {
                    cntx.delete(redundantSongEntity)
                    songsArray.remove(at: index)
                }
            }
        }
        //Reset order
        songsArray = songsArray.enumerated().map { (index, song) in
            song.songOrder = Int32(index)
            return song
        }
        saveContext(cntx: cntx)
        return songsArray
    }
    
    func processSong(toProcess song: SongEntity,
                     cntx: NSManagedObjectContext? = nil) {
        let cntx = cntx ?? self.managedObjectContext!
        let songUrl = self.getSongPath(song: song)
        let songAsset = AVAsset.init(url: songUrl)
        if !songAsset.commonMetadata.isEmpty {
            let meta = songAsset.commonMetadata
            if let title = meta.index(where: { el in el.commonKey == "title"}) {
                song.songTitle = meta[title].value as? String
            }
            if let artist = meta.index(where: { el in el.commonKey == "artist"}) {
                song.songTitle = meta[artist].value as? String
            }
            //if let artwork = meta.index(where: { el in el.commonKey == "artwork"}) {
            //let imageData = meta.value as! Data
            // song.songArtwork = UIImageJPEGRepresentation(UIImage(data: imageData)!, 1) as NSData?
            //}
        }
        if song.songArtist == nil || song.songTitle == nil {
            song.songArtist = songUrl.deletingPathExtension().lastPathComponent
            song.songTitle = ""
            if let tokSongName = song.songArtist?.characters.split(separator: "-")
            {
                if tokSongName.count == 2 {
                    song.songArtist = String(tokSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    song.songTitle = String(tokSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
        }
        if song.songArtwork == nil {
            //put placeholder
        }
        song.isProcessed = true
        saveContext(cntx: cntx)
    }
    
}
