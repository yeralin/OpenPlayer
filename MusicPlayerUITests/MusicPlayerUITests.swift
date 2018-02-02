//
//  MusicPlayerUITests.swift
//  MusicPlayerUITests
//
//  Created by Daniyar Yeralin on 5/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import XCTest
@testable import MusicPlayer

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        
        self.tap()
        
        self.typeText(text)
    }
    
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}

class MusicPlayerUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateAndDeletePlaylist(){
        
        let app = XCUIApplication()
        let playlistsNavigationBar = app.navigationBars["Playlists"]
        playlistsNavigationBar.buttons["Add"].tap()
        
        let createNewPlaylistAlert = app.alerts["Create new playlist"]
        createNewPlaylistAlert.collectionViews.textFields["Playlist Name"].typeText("Test 3")
        createNewPlaylistAlert.buttons["OK"].tap()
        app.tables.staticTexts["Test 3"].tap()
        app.navigationBars["Test 3"].buttons["Playlists"].tap()
        playlistsNavigationBar.buttons["Edit"].tap()
        let tablesQuery = app.tables
        tablesQuery.buttons["Delete Test 3"].tap()
        tablesQuery.buttons["Delete"].tap()
        app.alerts["Warning"].buttons["Delete"].tap()
        app.navigationBars["Playlists"].buttons["Done"].tap()
        
    }
    
    //Add Seek test
    func testPlayPauseRenameSong() {
        let FIRST_CELL = 0
        let PLAY_BUTTON = 0
        let EDIT_BUTTON = 2
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let test1StaticText = tablesQuery.staticTexts["Test 1"]
        test1StaticText.tap()
        let testingCell = tablesQuery.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[FIRST_CELL]
        
        testingCell.buttons.allElementsBoundByIndex[PLAY_BUTTON].tap()
        
        let playlistsButton = app.navigationBars["Test 1"].buttons["Playlists"]
        playlistsButton.tap()
        test1StaticText.tap()
        testingCell.buttons.allElementsBoundByIndex[PLAY_BUTTON].tap()
        testingCell.buttons.allElementsBoundByIndex[EDIT_BUTTON].tap()
        let changeTheSongNameAlert = app.alerts["Change the song name"]
        let textField = changeTheSongNameAlert.collectionViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        let doneButton = changeTheSongNameAlert.buttons["Done"]
        textField.typeText(" Test")
        
        doneButton.tap()
        testingCell.buttons.allElementsBoundByIndex[PLAY_BUTTON].tap()
        playlistsButton.tap()
        test1StaticText.tap()
        testingCell.buttons.allElementsBoundByIndex[PLAY_BUTTON].tap()
        testingCell.buttons.allElementsBoundByIndex[EDIT_BUTTON].tap()
        textField.clearAndEnterText(text: "Test")
        doneButton.tap()
        playlistsButton.tap()
        
    }
    
    func testMoveSongBetweenPlaylist() {
        let FIRST_CELL = 0
        let MOVE_BUTTON = 2
        let SONG_LABLE = 1
        let ARTIST_LABLE = 0
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Test 1"].tap()
        let testingCell = tablesQuery.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[FIRST_CELL]
        let toTestSongName = testingCell.staticTexts.allElementsBoundByAccessibilityElement[SONG_LABLE].label
        let toTestArtistName = testingCell.staticTexts.allElementsBoundByAccessibilityElement[ARTIST_LABLE].label
        testingCell.buttons.allElementsBoundByIndex[MOVE_BUTTON].tap()
        app.toolbars.buttons["Done"].tap()
        app.navigationBars["Test 1"].buttons["Playlists"].tap()
        tablesQuery.staticTexts["Test 2"].tap()
        let songName = testingCell.staticTexts.allElementsBoundByAccessibilityElement[SONG_LABLE].label
        let artistName = testingCell.staticTexts.allElementsBoundByAccessibilityElement[ARTIST_LABLE].label
        assert((songName == toTestSongName) && (artistName == toTestArtistName), "Moved song does not match original")
    }
    
    func testChangePlaylistRowPositions() {
        let SONG_LABLE = 1
        let CELL_REORDER_BUTTON = 4
        let app = XCUIApplication()
        app.navigationBars["Playlists"].buttons["Edit"].tap()
        let test1 = app.tables.buttons["Reorder Test 1"]
        let test2 = app.tables.buttons["Reorder Test 2"]
        test1.press(forDuration: 1.5, thenDragTo: test2)
        app.navigationBars["Playlists"].buttons["Done"].tap()
        //
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Test 2"].tap()
        
        let test2NavigationBar = app.navigationBars["Test 2"]
        test2NavigationBar.buttons["Edit"].tap()
        let cell1 = tablesQuery.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[0]
        let cell2 = tablesQuery.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[1]
        let reorderCellButton = cell1.buttons.allElementsBoundByIndex[CELL_REORDER_BUTTON]
        let toTestSongName = cell1.staticTexts.allElementsBoundByIndex[SONG_LABLE].label
        reorderCellButton.press(forDuration: 1.5, thenDragTo: cell2)
        test2NavigationBar.buttons["Done"].tap()
        app.navigationBars["Test 2"].buttons["Playlists"].tap()
        
        app.navigationBars["Playlists"].buttons["Edit"].tap()
        test2.press(forDuration: 1.5, thenDragTo: test1)
        app.navigationBars["Playlists"].buttons["Done"].tap()
        tablesQuery.staticTexts["Test 2"].tap()
        let cell2SongName = tablesQuery.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[1].staticTexts.allElementsBoundByIndex[SONG_LABLE].label
        assert(cell2SongName == toTestSongName, "SongName does not match before changing its position")
    }
    
    func testReusableCells() {
        let FIRST_CELL = 0
        let NEXT_REUSABLE_CELL = 10
        let PLAY_BUTTON = 0
        let app = XCUIApplication()
        let tablesQuery = app.tables.allElementsBoundByIndex[0]
        let test1StaticText = app.tables.staticTexts["Test 1"]
        test1StaticText.tap()
        let testingCell = app.tables.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[FIRST_CELL]
        testingCell.buttons.allElementsBoundByIndex[PLAY_BUTTON].tap()
        for _ in 1...3 {
            tablesQuery.swipeUp()
        }
        let nextReusableCell = app.tables.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[NEXT_REUSABLE_CELL]
        nextReusableCell.buttons.allElementsBoundByIndex[PLAY_BUTTON].tap()
        
    }
    
}
