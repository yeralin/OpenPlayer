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
    
    func resetSongsOrder(songArray: [SongEntity], cntx: NSManagedObjectContext) {
        for (index, _) in songArray.enumerated() {
            songArray[index].songOrder = Int32(index)
        }
        saveContext(cntx: cntx)
    }
    
    func populateSongs(forPlaylist: PlaylistEntity, playlistName: String, cntx: NSManagedObjectContext) -> [SongEntity] {
        let songsArray = getSongArray(cntx: cntx, playlist: forPlaylist)
        resetSongsOrder(songArray: songsArray, cntx: cntx)
        
        var toMatchWithAudioFiles = songsArray
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
                    _ = processAndCreateSong(songUrl: entry, playlist: forPlaylist, cntx: cntx)
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
                cntx.delete(redundantSongEntity)
                saveContext(cntx: cntx)
            }
        }
        //Get updated content
        return getSongArray(cntx: cntx, playlist: forPlaylist)
    }
    
    func processAndCreateSong(songUrl: URL, playlist: PlaylistEntity, cntx: NSManagedObjectContext) -> Int32 {
        let song = SongEntity(context: cntx)
        let songAsset = AVAsset.init(url: songUrl)
        song.songName = songUrl.lastPathComponent
        playlist.addToSongs(song)
        song.songOrder = {
            let next: Int32 = 1
            let songsArray = getSongArray(cntx: cntx, playlist: playlist)
            let songsMaxOrder = songsArray.max(by: {$0.songOrder < $1.songOrder})?.songOrder
            if songsMaxOrder == nil {
                return 0
            }
            return songsMaxOrder! + next
        }()
        if !songAsset.commonMetadata.isEmpty {
            for meta in songAsset.commonMetadata {
                if meta.commonKey == "title" {
                    song.songTitle = meta.value as? String
                }
                if meta.commonKey == "artist" {
                    song.songArtist = meta.value as? String
                }
                if meta.commonKey == "artwork" {
                    let imageData = meta.value as! Data
                    song.songArtwork = UIImageJPEGRepresentation(UIImage(data: imageData)!, 1) as NSData?
                }
            }
            
        }
        if song.songArtist == nil || song.songTitle == nil {
            song.songArtist = songUrl.deletingPathExtension().lastPathComponent
            let tokenizedSongName = song.songArtist?.characters.split(separator: "-")
            if tokenizedSongName?.count == 2 {
                song.songArtist = String(tokenizedSongName![0]).replacingOccurrences(of: "_", with: " ")
                song.songTitle = String(tokenizedSongName![1]).replacingOccurrences(of: "_", with: " ")
            } else {
                song.songTitle = ""
            }
        }
        if song.songArtwork == nil {
            print("Set placeholder")
            //put placeholder
        }
        saveContext(cntx: cntx)
        return song.songOrder
    }
    
}
