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
        if icon.exists {
            let iconFrame = icon.frame
            let springboardFrame = springboard.frame
            icon.press(forDuration: 1.3)
            springboard.buttons["Delete App"].tap()
            sleep(1)
            springboard.alerts.buttons["Delete"].tap()
        }
    }
}
