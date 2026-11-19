//
//  Springboard.swift
//  MusicPlayerUITests
//
//  Created by Daniyar Yeralin on 5/12/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import XCTest

class Springboard {
    
    static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    
    /**
     Terminate and delete the app via springboard
     */
    class func deleteMyApp() {
        XCUIApplication().terminate()
        
        // Force delete the app from the springboard
        let icon = springboard.icons["OpenPlayer"]
        guard icon.waitForExistence(timeout: 5) else {
            return // Not installed yet.
        }
        icon.press(forDuration: 1.3)
        // Each step's button appears only after an animation, sometimes
        // several seconds late on CI, so wait for it instead of tapping at once.
        tap(springboard.buttons["Remove App"])
        tap(springboard.alerts.buttons["Delete App"])
        tap(springboard.alerts.buttons["Delete"])
        XCTAssertTrue(icon.waitForNonExistence(timeout: 10), "OpenPlayer was not deleted")
    }

    private class func tap(_ button: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        guard button.waitForExistence(timeout: 15) else {
            XCTFail("SpringBoard never showed \(button)", file: file, line: line)
            return
        }
        button.tap()
    }
}
