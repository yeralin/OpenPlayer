//
//  PersistanceController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData

class PersistanceController {
    
    var fm: FileManager
    var docsUrl: URL
    
    init() {
        fm = FileManager.default
        docsUrl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }

    func overrideInit(overrideFm: FileManager, overrideDocsUrl: URL) {
        fm = overrideFm
        docsUrl = overrideDocsUrl
    }
    
    func fetchData(entityName: String, sortIn: NSSortDescriptor?, predicate: NSPredicate?, cntx: NSManagedObjectContext) -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if (sortIn != nil) {
            fetchRequest.sortDescriptors = [sortIn!]
        }
        if (predicate != nil) {
            fetchRequest.predicate = predicate
        }
        var fetchedObjects: [NSManagedObject]!
        do {
            fetchedObjects = try cntx.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("Could not fetch \(entityName) entity")
        }
        return fetchedObjects
    }
    
    func deleteEntity(toDelete: NSManagedObject, cntx: NSManagedObjectContext) {
        do {
            if let toDeletePlaylist = toDelete as? PlaylistEntity {
                let playlistPath = PlaylistPersistancyManager.sharedInstance.getPlaylistPath(playlist: toDeletePlaylist)
                try fm.removeItem(at: playlistPath)
            } else if let toDeleteSong = toDelete as? SongEntity {
                let songPath = SongPersistancyManager.sharedInstance.getSongPath(song: toDeleteSong)
                try fm.removeItem(at: songPath)
            } else {
                print("Error: could not identify entity of \"toDelete\" object")
                return
            }
            cntx.delete(toDelete)
        } catch {
            print("Could not delete entity  \(String(describing: toDelete))")
        }
        saveContext(cntx: cntx)
        
    }
    
    func saveContext(cntx: NSManagedObjectContext) {
        do {
            try cntx.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")        }
    }
}
