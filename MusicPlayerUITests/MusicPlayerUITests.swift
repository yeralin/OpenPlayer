//
//  MusicPlayerUITests.swift
//  MusicPlayerUITests
//
//  Created by Daniyar Yeralin on 5/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import XCTest
import SwiftIcons
@testable import MusicPlayer

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        self.tap()
        let deleteString = stringValue.map { _ in "\u{8}" }.joined(separator: "")
        self.typeText(deleteString)
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
    
    private var launcher: XCUIApplication? = nil;
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Springboard.deleteMyApp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        launcher = XCUIApplication()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatePlaylist() {
        launcher?.launch()
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let playlistsNavigationBar = app.navigationBars["Playlists"]
        playlistsNavigationBar.buttons["Add"].tap()
        let createNewPlaylistAlert = app.alerts["Create new playlist"]
        createNewPlaylistAlert.collectionViews.textFields["Playlist Name"].typeText("Test")
        createNewPlaylistAlert.buttons["OK"].tap()
        tablesQuery.staticTexts["Test"].tap()
        app.navigationBars["Test"].buttons["Playlists"].tap()
        playlistsNavigationBar.buttons["Edit"].tap()
        tablesQuery.buttons["Delete Test"].tap()
        tablesQuery.buttons["Delete"].tap()
        app.alerts["Warning"].buttons["Delete"].tap()
        app.navigationBars["Playlists"].buttons["Done"].tap()
        XCTAssertTrue(tablesQuery.cells.count == 0)
    }
    
    func testFailDuplicatePlaylist() {
        launcher?.launch()
        let app = XCUIApplication()
        let playlistsNavigationBar = app.navigationBars["Playlists"]
        playlistsNavigationBar.buttons["Add"].tap()
        let createNewPlaylistAlert = app.alerts["Create new playlist"]
        createNewPlaylistAlert.collectionViews.textFields["Playlist Name"].typeText("Test")
        createNewPlaylistAlert.buttons["OK"].tap()
        playlistsNavigationBar.buttons["Add"].tap()
        createNewPlaylistAlert.collectionViews.textFields["Playlist Name"].typeText("Test")
        createNewPlaylistAlert.buttons["OK"].tap()
        XCTAssertTrue(app.alerts["Error"].visible())
        app.alerts["Error"].buttons["OK"].tap()
    }
    
    func testChangePlaylistRowPositions() {
        launcher?.launchArguments.append("TestFirst:1")
        launcher?.launchArguments.append("TestSecond:0")
        launcher?.launch()
        let FIRST_CELL = 0
        let SECOND_ROW = 1
        let app = XCUIApplication()
        let tablesQuery = app.tables
        app.navigationBars["Playlists"].buttons["Edit"].tap()
        let testFirstPlaylist = tablesQuery.buttons["Reorder TestFirst"]
        let testSecondPlaylist = tablesQuery.buttons["Reorder TestSecond"]
        let posOfFirst = testFirstPlaylist.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let posToMove = testSecondPlaylist.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 6))
        posOfFirst.press(forDuration: 0.5, thenDragTo: posToMove)
        app.navigationBars["Playlists"].buttons["Done"].tap()
        tablesQuery.staticTexts.element(boundBy: SECOND_ROW).tap()
        let testingCell = tablesQuery.cells.element(boundBy: FIRST_CELL)
        XCTAssertTrue(testingCell.exists)
    }
    
    func testPlayPauseSong() {
        launcher?.launchArguments.append("Test:1")
        launcher?.launch()
        let FIRST_CELL = 0
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Test"].tap()
        let testingCell = tablesQuery.cells.element(boundBy: FIRST_CELL)
        let playPauseButton = testingCell.buttons["play"]
        playPauseButton.tap()
        sleep(2)
        XCTAssertTrue(testingCell.buttons["play"].label == FontType.ionicons(.iosPause).text)
        playPauseButton.tap()
        XCTAssertTrue(testingCell.buttons["play"].label == FontType.ionicons(.play).text)
    }
    
    func testRenameSong() {
        launcher?.launchArguments.append("Test:1")
        launcher?.launch()
        let FIRST_CELL = 0
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Test"].tap()
        let testingCell = tablesQuery.cells.element(boundBy: FIRST_CELL)
        testingCell.buttons["edit"].tap()
        let changeTheSongNameAlert = app.alerts["Change the song name"]
        let artistTextField = changeTheSongNameAlert.textFields.element(boundBy: 0)
        let titleTextField = changeTheSongNameAlert.textFields.element(boundBy: 1)
        let doneButton = changeTheSongNameAlert.buttons["Done"]
        artistTextField.clearAndEnterText(text: "Hello")
        titleTextField.clearAndEnterText(text: "World")
        doneButton.tap()
        XCTAssertTrue(testingCell.staticTexts["artist"].label == "Hello")
        XCTAssertTrue(testingCell.staticTexts["title"].label == "World")
    }
    
    func testPlayTwoSongsConsecutively() {
        launcher?.launchArguments.append("Test:2")
        launcher?.launch()
        let FIRST_CELL = 0
        let SECOND_CELL = 1
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Test"].tap()
        let firstTestingCell = tablesQuery.cells.element(boundBy: FIRST_CELL)
        let secondTestingCell = tablesQuery.cells.element(boundBy: SECOND_CELL)
        firstTestingCell.buttons["play"].tap()
        sleep(2)
        secondTestingCell.buttons["play"].tap()
        XCTAssertTrue(firstTestingCell.buttons["play"].label == FontType.ionicons(.play).text)
        XCTAssertTrue(secondTestingCell.buttons["play"].label == FontType.ionicons(.iosPause).text)
    }
    
    func testMoveSongFromOnePlaylistToAnother() {
        launcher?.launchArguments.append("TestFirst:1")
        launcher?.launchArguments.append("TestSecond:0")
        launcher?.launch()
        let FIRST_CELL = 0
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["TestFirst"].tap()
        let testingCell = tablesQuery.cells.element(boundBy: FIRST_CELL)
        testingCell.buttons["move"].tap()
        app/*@START_MENU_TOKEN@*/.pickerWheels["TestSecond"]/*[[".pickers.pickerWheels[\"TestSecond\"]",".pickerWheels[\"TestSecond\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.navigationBars["TestFirst"].buttons["Playlists"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["TestSecond"]/*[[".cells.staticTexts[\"TestSecond\"]",".staticTexts[\"TestSecond\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(1) // Let Song Table to fully load
        XCTAssertTrue(tablesQuery.cells.count == 1)
    }
}
