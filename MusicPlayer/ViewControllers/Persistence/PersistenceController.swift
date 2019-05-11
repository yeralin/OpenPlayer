//
//  PersistenceController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersistenceController {
    
    var fm: FileManager = FileManager.default
    var docsUrl: URL
    lazy var managedObjectContext: NSManagedObjectContext! = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    init() {
        do {
            docsUrl = try fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch let error {
            fatalError("Could not fetch path to root directory: \(error)")
        }
    }
    
    internal func _fetchCount(entityName: String, cntxt: NSManagedObjectContext? = nil) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var count = -1
        do {
            count = try cntxt?.count(for: fetchRequest) ?? -1
        } catch {
            log.error("Could not get count for \(entityName) entity")
        }
        return count
    }
    
    internal func _fetchData(entityName: String, sortIn: NSSortDescriptor?, predicate: NSPredicate?, cntxt: NSManagedObjectContext? = nil) -> [NSManagedObject] {
        let cntxt = cntxt ?? self.managedObjectContext!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let sortIn = sortIn {
            fetchRequest.sortDescriptors = [sortIn]
        }
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        var fetchedObjects: [NSManagedObject]?
        do {
            fetchedObjects = try cntxt.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            log.error("Could not fetch \(entityName) entity")
        }
        return fetchedObjects!
    }
    
    internal func validateContext(context: NSManagedObjectContext?) throws -> NSManagedObjectContext {
        guard let context = context ?? self.managedObjectContext else {
            throw "Could not fetch the persistence context"
        }
        return context
    }
    
    internal func saveContext(cntxt: NSManagedObjectContext? = nil) throws {
        guard let cntxt = cntxt ?? self.managedObjectContext else {
            throw "Could not fetch the persistence context"
        }
        do {
            try cntxt.save()
        } catch let error as NSError  {
            throw "Could not save the persistence context: \(error), \(error.userInfo)"
        }
    }
}
