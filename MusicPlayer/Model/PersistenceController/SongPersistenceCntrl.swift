//
//  SongPersistencyManager.swift
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

enum SongPersistenceCntrlError: Error {
    case FileAlreadyExists
    case UnknownError(msg: String)
}

class SongPersistencyManager: PersistenceController {
    
    static let sharedInstance = SongPersistencyManager()
    
    func getSongsArray(playlist: PlaylistEntity,
                      cntxt: NSManagedObjectContext? = nil) throws -> [SongEntity] {
        let cntxt = try validateContext(context: cntxt)
        guard let songArray = _fetchData(entityName: "SongEntity",
                                         sortIn: NSSortDescriptor(key: "songOrder", ascending: true),
                                         predicate: NSPredicate(format: "%K == %@", "playlist.playlistName", playlist.playlistName!),
                cntxt: cntxt) as? [SongEntity] else {
            throw "Could not cast data to [SongEntity]"
        }
        return songArray
    }

    public func getSongPath(song: SongEntity) throws -> URL {
        if let songName = song.songName, let playlistName = song.playlist?.playlistName {
            return docsUrl.appendingPathComponent(playlistName).appendingPathComponent(songName)
        } else {
            throw "Could not extract meta from song entity"
        }
    }

    func deleteSong(song: SongEntity, cntxt: NSManagedObjectContext? = nil) throws {
        let cntxt = try validateContext(context: cntxt)
        do {
            let songPath = try getSongPath(song: song)
            try fm.removeItem(at: songPath)
            cntxt.delete(song)
            try saveContext(cntxt: cntxt)
        } catch {
            log.error("Could not delete Song entity: \(String(describing: song))")
        }
    }

    func moveSong(toMoveSong: SongEntity, fromPlaylist: PlaylistEntity, toPlaylist: PlaylistEntity) throws {
        do {
            guard let songName = toMoveSong.songName else {
                throw "Could not extract songName"
            }
            let playlistPerstManager = PlaylistPersistencyManager.sharedInstance
            let toPlaylistPath = try playlistPerstManager.getPlaylistPath(playlist: toPlaylist)
            let toMovePath = toPlaylistPath.appendingPathComponent(songName)
            if fm.fileExists(atPath: toMovePath.path) {
                throw SongPersistenceCntrlError.FileAlreadyExists
            }
            try fm.moveItem(at: getSongPath(song: toMoveSong), to: toMovePath)
            fromPlaylist.removeFromSongs(toMoveSong)
            toPlaylist.addToSongs(toMoveSong)
        } catch SongPersistenceCntrlError.FileAlreadyExists {
            throw SongPersistenceCntrlError.FileAlreadyExists
        } catch {
            throw SongPersistenceCntrlError.UnknownError(msg: "Could not move song to a different playlist: \(error)")
        }
    }

    func renameSong(song: SongEntity, newArtist: String, newTitle: String, cntxt: NSManagedObjectContext? = nil) throws {
        let cntxt = try validateContext(context: cntxt)
        if !newArtist.isEmpty && !newTitle.isEmpty {
            song.songArtist = newArtist
            song.songTitle = newTitle
            try saveContext(cntxt: cntxt)
        }
        
    }
    
    func populateSongs(forPlaylist: PlaylistEntity,
                       cntxt: NSManagedObjectContext? = nil) throws -> [SongEntity] {
        let cntxt = try validateContext(context: cntxt)
        guard let playlistName = forPlaylist.playlistName else {
            throw "Could not extract playlistName"
        }
        var songsArray = try getSongsArray(playlist: forPlaylist, cntxt: cntxt)
        var songsToMatchWithAudioFiles = songsArray
        let playlistPath: URL = docsUrl.appendingPathComponent(playlistName)
        let filePaths = try fm.contentsOfDirectory(at: playlistPath,
                                                    includingPropertiesForKeys: nil)
        // Match song entities with their corresponding audio files:
        // If a new audio file is found, create a new song entity
        for filePath in filePaths {
            if let fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, filePath.pathExtension as CFString, nil)?.takeRetainedValue() {
                let isAudioFile = UTTypeConformsTo(fileUTI, kUTTypeAudio)
                if isAudioFile {
                    let audioFileName = filePath.lastPathComponent
                    if let index = songsToMatchWithAudioFiles.firstIndex(where: { el in el.songName == audioFileName }) {
                        songsToMatchWithAudioFiles.remove(at: index)
                    } else {
                        // New audio file is found, create corresponding SongEntity
                        let song = SongEntity(context: cntxt)
                        song.songUrl = nil
                        song.songName = audioFileName
                        song.songOrder = -1
                        song.isProcessed = false
                        forPlaylist.addToSongs(song)
                        songsArray.append(song)
                    }
                }
            }
        }
        if !songsToMatchWithAudioFiles.isEmpty {
            // There are songs w/o corresponding audio file
            // Probably were removed from FS, perform a cleanup
            for redundantSongEntity in songsToMatchWithAudioFiles {
                if let index = songsArray.firstIndex(where: { el in el == redundantSongEntity}) {
                    cntxt.delete(redundantSongEntity)
                    songsArray.remove(at: index)
                }
            }
        }
        // Reset order
        songsArray = try resetSongOrder(songArray: songsArray)
        try saveContext(cntxt: cntxt)
        return songsArray
    }

    public func resetSongOrder(songArray: [SongEntity],
                               cntxt: NSManagedObjectContext? = nil) throws -> [SongEntity] {
        let cntxt = try validateContext(context: cntxt)
        for (index, _) in songArray.enumerated() {
            songArray[index].songOrder = Int32(index)
        }
        try saveContext(cntxt: cntxt)
        return songArray
    }

    func processSong(toProcess song: SongEntity,
                     cntxt: NSManagedObjectContext? = nil) throws {
        let cntxt = try validateContext(context: cntxt)
        let songPath = try getSongPath(song: song)
        let songAsset = AVAsset.init(url: songPath)
        if !songAsset.commonMetadata.isEmpty {
            let meta = songAsset.commonMetadata
            if let title = meta.firstIndex(where: { el in el.commonKey?.rawValue == "title"}) {
                song.songTitle = meta[title].value as? String
            }
            if let artist = meta.firstIndex(where: { el in el.commonKey?.rawValue == "artist"}) {
                song.songTitle = meta[artist].value as? String
            }
            //if let artwork = meta.index(where: { el in el.commonKey == "artwork"}) {
            //let imageData = meta.value as! Data
            // song.songArtwork = UIImageJPEGRepresentation(UIImage(data: imageData)!, 1) as NSData?
            //}
        }
        if song.songArtist == nil || song.songTitle == nil {
            song.songArtist = songPath.deletingPathExtension().lastPathComponent
            song.songTitle = ""
            if let tokSongName = song.songArtist?.split(separator: "-", maxSplits: 1), tokSongName.count == 2 {
                song.songArtist = String(tokSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                song.songTitle = String(tokSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
        }
        if song.songArtwork == nil {
            // TODO: Put placeholder
        }
        song.isProcessed = true
        try saveContext(cntxt: cntxt)
    }
    
    private func getPlaylistPath(playlist: PlaylistEntity) throws -> URL {
        guard let playlistName = playlist.playlistName else {
            throw "Could not extract playlistName from playlist entity"
        }
        let playlistPath = docsUrl.appendingPathComponent(playlistName)
        if !fm.fileExists(atPath: playlistPath.absoluteString) {
            throw "Playlist does not exist at path: \(playlistPath)"
        }
        return playlistPath
    }
    
}
