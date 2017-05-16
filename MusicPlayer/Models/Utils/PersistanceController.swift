//
//  PersistanceController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData

let fm = FileManager.default
let docsUrl: URL! = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

class PersistanceController {
    
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
    
    func deleteEntity(toDelete: NSManagedObject, toDeleteUrl: URL, cntx: NSManagedObjectContext) {
        do {
            
            try fm.removeItem(at: toDeleteUrl)
            cntx.delete(toDelete)
        } catch {
            print("Could not delete entity  \(String(describing: toDelete))")
        }
        saveContext(cntx: cntx)
        
    }
    
    func saveContext(cntx: NSManagedObjectContext) {
        do {
            try cntx.save()
        } catch {
            print("Could not save context")
        }
    }
}
