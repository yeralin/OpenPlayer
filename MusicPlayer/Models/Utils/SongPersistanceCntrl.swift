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
    
    func getSongArray(cntx: NSManagedObjectContext, playlist: PlaylistEntity) -> [SongEntity] {
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
            print("Could not move song to a different playlist: \(error)")
        }
    }
    
    func populateSongs(forPlaylist: PlaylistEntity, cntx: NSManagedObjectContext) -> [SongEntity] {
        let playlistName = forPlaylist.playlistName!
        var songsArray = getSongArray(cntx: cntx, playlist: forPlaylist)
        var toMatchWithAudioFiles = songsArray
        let playlistUrl: URL = docsUrl.appendingPathComponent(playlistName) //Inside playlist dir
        let contentsArray = try! fm.contentsOfDirectory(at: playlistUrl,
                                                        includingPropertiesForKeys: nil)
        var nextOrder: Int32 = {
            let next: Int32 = 1
            let songsArray = getSongArray(cntx: cntx, playlist: forPlaylist)
            if let songsMaxOrder = songsArray.max(by: {$0.songOrder < $1.songOrder})?.songOrder {
                return songsMaxOrder + next
            } else {
                return 0
            }
        }()
        contentsArray.forEach {
            entry in
            let fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, entry.pathExtension as CFString, nil)?.takeRetainedValue()
            let ifAudio = UTTypeConformsTo(fileUTI!, kUTTypeAudio)
            if ifAudio {
                let index = toMatchWithAudioFiles.index(where: {el in el.songName == entry.lastPathComponent })
                if index == nil {
                    songsArray.append(processAndCreateSong(songUrl: entry, playlist: forPlaylist, songOrder: nextOrder, cntx: cntx))
                    nextOrder += 1
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
    
    func processAndCreateSong(songUrl: URL, playlist: PlaylistEntity, songOrder: Int32, cntx: NSManagedObjectContext) -> SongEntity {
        let song = SongEntity(context: cntx)
        let songAsset = AVAsset.init(url: songUrl)
        song.songName = songUrl.lastPathComponent
        song.songOrder = songOrder
        playlist.addToSongs(song)
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
            if let tokenizedSongName = song.songArtist?.characters.split(separator: "-")
            {
                if tokenizedSongName.count == 2 {
                    
                    song.songArtist = String(tokenizedSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    song.songTitle = String(tokenizedSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
        }
        if song.songArtwork == nil {
            //put placeholder
        }
        return song
    }
    
}
