//
//  TestUtils.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/22/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import CoreData


class TestUtils {
    
    let fm: FileManager
    let docsUrl: URL
    
    
    static let sharedInstance = TestUtils()
    
    init() {
        do {
            fm = FileManager.default
            docsUrl = try fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch let err {
            fatalError("Could not initialize TestUtils: \(err)")
        }
    }
    
    /*func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
     let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
     
     let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
     
     do {
     try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
     } catch {
     print("Adding in-memory persistent store failed")
     }
     
     let managedObjectContext = NSManagedObjectContext()
     managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
     
     return managedObjectContext
     }*/
    
    func createPlaylistWithTestData(playlistName: String, testEntires: Int)
    {
        
        let testPlaylist = docsUrl.appendingPathComponent(playlistName)
        do {
            try fm.createDirectory(at:testPlaylist, withIntermediateDirectories: true)
        } catch {
            print("Could not save test playlist: \(playlistName)")
        }
        let bundle = Bundle(for: type(of: self))
        guard let testFile = bundle.path(forResource: "test - test", ofType: "mp3") else {
            fatalError("Could not locate test data")
        }
        for i in 1...testEntires {
            do {
                try fm.copyItem(atPath: testFile, toPath: testPlaylist.appendingPathComponent("test - test_\(i).mp3").path)
            } catch let error {
                print("Something went wrong: \(error)")
            }
        }
    }
    
    
}
