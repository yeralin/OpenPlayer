//
//  MusicPlayerTests.swift
//  MusicPlayerTests
//
//  Created by Daniyar Yeralin on 5/21/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import XCTest
import CoreData
@testable import MusicPlayer

class MusicPlayerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateAndDeletePlaylist() {
        //let managedObjectContext = setUpInMemoryManagedObjectContext()
        let entity = NSEntityDescription.insertNewObjectForEntityForName("EntityName", inManagedObjectContext: managedObjectContext)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
