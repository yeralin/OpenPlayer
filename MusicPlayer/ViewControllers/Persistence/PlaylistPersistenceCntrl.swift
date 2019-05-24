//
//  PlaylistPersistencyManager.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData

class PlaylistPersistencyManager: PersistenceController {
    
    static let sharedInstance = PlaylistPersistencyManager()
    
    func createPlaylist(name: String, cntxt: NSManagedObjectContext? = nil) throws -> Int {
        let cntxt = try validateContext(context: cntxt)
        if !_fetchData(entityName: "PlaylistEntity",
                       sortIn: nil,
                       predicate: NSPredicate(format: "playlistName CONTAINS[cd] %@", name)).isEmpty {
            throw UIError.AlreadyExists(reason: "Playlist \"\(name)\" already exists")
        }
        let playlistPosition = fetchPlaylistSize()
        let playlistEntity = PlaylistEntity(context: cntxt)
        playlistEntity.playlistName = name
        playlistEntity.playlistOrder = Int32(playlistPosition)
        let newPlaylist = docsUrl.appendingPathComponent(name)
        do {
            try fm.createDirectory(at:newPlaylist, withIntermediateDirectories: true)
        } catch {
            throw "Could not save a playlist: \(String(describing: playlistEntity.playlistName))"
        }
        try saveContext(cntxt: cntxt)
        return playlistPosition
    }
    
    func getPlaylistArray(cntxt: NSManagedObjectContext? = nil) throws -> [PlaylistEntity] {
        let cntxt = try validateContext(context: cntxt)
        guard let playlistArray = _fetchData(entityName: "PlaylistEntity",
                                             sortIn: NSSortDescriptor(key: "playlistOrder", ascending: true),
                                             predicate: nil,
                                             cntxt: cntxt) as? [PlaylistEntity] else {
                                                throw "Could not cast data to [PlaylistEntity]"
        }
        return playlistArray
    }
    
    func deletePlaylist(playlist: PlaylistEntity, cntxt: NSManagedObjectContext? = nil) throws {
        let cntxt = try validateContext(context: cntxt)
        do {
            let playlistPath = try getPlaylistPath(playlist: playlist)
            try fm.removeItem(at: playlistPath)
            cntxt.delete(playlist)
            try saveContext(cntxt: cntxt)
        } catch let error {
            log.error("Could not delete playlist \(playlist.playlistName ?? "unknown"): \(error)")
        }
    }
    
    func wipePlaylists(cntxt: NSManagedObjectContext) throws {
        _ = try getPlaylistArray().map{cntxt.delete($0)}
        try saveContext(cntxt: cntxt)
    }
    
    func populatePlaylists(cntxt: NSManagedObjectContext? = nil) throws -> [PlaylistEntity] {
        let cntxt = try validateContext(context: cntxt)
        //Go through folders, if new found -> create playlist
        var playlistsToMatchWithDirs = try getPlaylistArray()
        let playlistDirectories = try fm.contentsOfDirectory(at:docsUrl,
                                                             includingPropertiesForKeys: nil)
        var isDir : ObjCBool = false
        // Match playlist entities with their corresponding playlist directories:
        // If a new playlist directory is found, create a new playlist entity
        for entryPath in playlistDirectories {
            let directoryName = entryPath.lastPathComponent
            if fm.fileExists(atPath: entryPath.path, isDirectory: &isDir) && isDir.boolValue {
                let index = playlistsToMatchWithDirs.firstIndex(where: {el in el.playlistName == directoryName })
                // playlist got matched, remove from array
                if index != nil {
                    playlistsToMatchWithDirs.remove(at: index!)
                } else {
                    // playlist wasn't found, create one
                    _ = try createPlaylist(name: entryPath.lastPathComponent, cntxt: cntxt)
                }
            }
        }
        if !playlistsToMatchWithDirs.isEmpty {
            // There are playlists w/o corresponding dir
            // Probably were removed from FS, perform a cleanup
            for redundantPlaylistEntity in playlistsToMatchWithDirs {
                try deletePlaylist(playlist: redundantPlaylistEntity)
            }
            playlistsToMatchWithDirs = try getPlaylistArray(cntxt: cntxt)
        }
        // Get updated content
        return try resetPlaylistsOrder(playlistArray: try getPlaylistArray(cntxt: cntxt), cntxt: cntxt)
    }
    
    public func resetPlaylistsOrder(playlistArray: [PlaylistEntity],
                                    cntxt: NSManagedObjectContext? = nil) throws -> [PlaylistEntity] {
        let cntxt = try validateContext(context: cntxt)
        for (index, _) in playlistArray.enumerated() {
            playlistArray[index].playlistOrder = Int32(index)
        }
        try saveContext(cntxt: cntxt)
        return playlistArray
    }
    
    private func fetchPlaylistSize() -> Int {
        return self._fetchCount(entityName: "PlaylistEntity")
    }
    
    internal func getPlaylistPath(playlist: PlaylistEntity) throws -> URL {
        guard let playlistName = playlist.playlistName else {
            throw "Could not extract playlistName from playlist entity"
        }
        let playlistUrl = docsUrl.appendingPathComponent(playlistName)
        if !fm.fileExists(atPath: playlistUrl.path) {
            throw "Playlist does not exist at path: \(playlistUrl)"
        }
        return playlistUrl
    }
}
