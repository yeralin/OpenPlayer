//
//  PersistanceController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersistanceController {
    
    var fm: FileManager = FileManager.default
    var docsUrl: URL
    lazy var managedObjectContext: NSManagedObjectContext! = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    init() {
        docsUrl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    func fetchData(entityName: String, sortIn: NSSortDescriptor?, predicate: NSPredicate?, cntx: NSManagedObjectContext? = nil) -> [NSManagedObject] {
        let cntx = cntx ?? self.managedObjectContext!
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
            log.error("Could not fetch \(entityName) entity")
        }
        return fetchedObjects
    }
    
    func deleteEntity(toDelete: NSManagedObject, cntx: NSManagedObjectContext? = nil) {
        let cntx = cntx ?? self.managedObjectContext!
        do {
            if let toDeletePlaylist = toDelete as? PlaylistEntity {
                let playlistPath = PlaylistPersistancyManager.sharedInstance.getPlaylistPath(playlist: toDeletePlaylist)
                try fm.removeItem(at: playlistPath)
            } else if let toDeleteSong = toDelete as? SongEntity {
                let songPath = SongPersistancyManager.sharedInstance.getSongPath(song: toDeleteSong)
                try fm.removeItem(at: songPath)
            } else {
                log.error("Could not identify entity of \"toDelete\" object")
                return
            }
            cntx.delete(toDelete)
        } catch {
            log.error("Could not delete entity  \(String(describing: toDelete))")
        }
        saveContext(cntx: cntx)
        
    }
    
    func saveContext(cntx: NSManagedObjectContext? = nil) {
        let cntx = cntx ?? self.managedObjectContext!
        do {
            try cntx.save()
        } catch let error as NSError  {
            log.error("Could not save context: \(error), \(error.userInfo)")        }
    }
}
