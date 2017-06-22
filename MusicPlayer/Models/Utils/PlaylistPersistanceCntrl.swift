//
//  PlaylistPersistancyManager.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData

class PlaylistPersistancyManager: PersistanceController {
    
    static let sharedInstance = PlaylistPersistancyManager()
    
    func getPlaylistArray(cntx: NSManagedObjectContext? = nil) -> [PlaylistEntity] {
        let cntx = cntx ?? self.managedObjectContext!
        return fetchData(entityName: "PlaylistEntity",
                         sortIn: NSSortDescriptor(key: "playlistOrder", ascending: true),
                         predicate: nil,
                         cntx: cntx) as! [PlaylistEntity]
    }
    
    func getPlaylistPath(playlist: PlaylistEntity) -> URL {
        let playlistName = playlist.playlistName
        return docsUrl.appendingPathComponent(playlistName!)
    }
    
    func resetPlaylistsOrder(playlistArray: [PlaylistEntity],
                             cntx: NSManagedObjectContext? = nil) {
        for (index, _) in playlistArray.enumerated() {
            playlistArray[index].playlistOrder = Int32(index)
        }
        if let cntx = cntx ?? self.managedObjectContext {
            saveContext(cntx: cntx)
        }
    }
    
    func populatePlaylists(cntx: NSManagedObjectContext? = nil) -> [PlaylistEntity] {
        let cntx = cntx ?? self.managedObjectContext!
        var playlistArray = getPlaylistArray(cntx: cntx)
        //Go through folders, if new found -> create playlist
        var toMatchWithDirs = playlistArray
        let contentsArray = try! fm.contentsOfDirectory(at:docsUrl,
                                                        includingPropertiesForKeys: nil)
        var nextOrder: Int32 = {
            let next: Int32 = 1
            let playlistArray = fetchData(entityName: "PlaylistEntity",
                                          sortIn: NSSortDescriptor(key: "playlistOrder", ascending: true),
                                          predicate: nil,
                                          cntx: cntx) as! [PlaylistEntity]
            if let playlistMaxOrder = playlistArray.max(by: {$0.playlistOrder < $1.playlistOrder})?.playlistOrder {
                return playlistMaxOrder + next
            } else {
                return 0
            }
        }()
        var isDir : ObjCBool = false
        for entryPath in contentsArray {
            if fm.fileExists(atPath: entryPath.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    let index = toMatchWithDirs.index(where: {el in el.playlistName == entryPath.lastPathComponent })
                    if index == nil {
                        _ = createPlaylist(name: entryPath.lastPathComponent, order: nextOrder, cntx: cntx)
                        nextOrder += 1
                    } else {
                        //Remove playlists to find unlinked one
                        toMatchWithDirs.remove(at: index!)
                    }
                }
            }
        }
        
        if !toMatchWithDirs.isEmpty {
            //There are playlists w/o corresponding dir
            //Probably was removed manually
            for redundantPlaylistEntity in toMatchWithDirs {
                cntx.delete(redundantPlaylistEntity)
                saveContext(cntx: cntx)
            }
            playlistArray = getPlaylistArray(cntx: cntx)
        }
        
        //Get updated content
        resetPlaylistsOrder(playlistArray: playlistArray, cntx: cntx)
        return getPlaylistArray(cntx: cntx)
    }
    
    func createPlaylist(name: String, order: Int32, cntx: NSManagedObjectContext? = nil) -> Int {
        let cntx = cntx ?? self.managedObjectContext!
        let playlistEntity = PlaylistEntity(context: cntx)
        playlistEntity.playlistName = name
        playlistEntity.playlistOrder = order
        let newPlaylist = docsUrl.appendingPathComponent(name)
        do {
            try fm.createDirectory(at:newPlaylist, withIntermediateDirectories: true)
        } catch {
            log.error("Could not save playlist: \(String(describing: playlistEntity.playlistName))")
        }
        saveContext(cntx: cntx)
        return Int(playlistEntity.playlistOrder)
    }
    
    func wipePlaylistCoreData(cntx: NSManagedObjectContext) {
        _ = (fetchData(entityName: "PlaylistEntity",
                       sortIn: NSSortDescriptor(key: "playlistOrder", ascending: true),
                       predicate: nil,
                       cntx: cntx) as! [PlaylistEntity]).map{cntx.delete($0)}
        saveContext(cntx: cntx)
    }
    
}
