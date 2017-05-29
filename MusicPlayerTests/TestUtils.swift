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
        fm = FileManager.default
        docsUrl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
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
    
    func wipeDocumentDir(){
        let contentsArray = try! fm.contentsOfDirectory(at: docsUrl, includingPropertiesForKeys: nil)
        for entry in contentsArray {
            do {
                try fm.removeItem(at: entry)
            } catch {
                print("Could not delete \(entry)")
            }
        }
    }
    
    func copyTestData()
    {
        let testPlaylist1 = docsUrl.appendingPathComponent("Test 1")
        let testPlaylist2 = docsUrl.appendingPathComponent("Test 2")
        do {
            try fm.createDirectory(at:testPlaylist2, withIntermediateDirectories: true)
            try fm.createDirectory(at:testPlaylist1, withIntermediateDirectories: true)
        } catch {
            print("Could not save test playlists")
        }
        let bundle = Bundle(for: type(of: self))
        if let testFile = bundle.path(forResource: "Test - Test", ofType: "mp3") {
            for i in 1...32 {
                do {
                    if (i % 2 == 1) {
                        try fm.copyItem(atPath: testFile, toPath: testPlaylist1.appendingPathComponent("Test - Test \(i).mp3").path)
                    } else {
                        try fm.copyItem(atPath: testFile, toPath: testPlaylist2.appendingPathComponent("Test - Test \(i).mp3").path)
                    }
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
                
            }
        }
    }
}
