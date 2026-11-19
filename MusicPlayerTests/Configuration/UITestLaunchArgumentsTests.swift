//
//  UITestLaunchArgumentsTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class UITestLaunchArgumentsTests: XCTestCase {

    func testParsesResetFlagAndPlaylistSeeds() {
        let arguments = UITestLaunchArguments(["--reset-state", "TestFirst:1", "TestSecond:0"])

        XCTAssertTrue(arguments.resetState)
        XCTAssertEqual(arguments.playlists, [.init(name: "TestFirst", songCount: 1),
                                             .init(name: "TestSecond", songCount: 0)])
    }

    func testNoArgumentsMeansNothingToDo() {
        XCTAssertEqual(UITestLaunchArguments([]), UITestLaunchArguments([]))
        XCTAssertFalse(UITestLaunchArguments([]).resetState)
        XCTAssertTrue(UITestLaunchArguments([]).playlists.isEmpty)
    }

    func testUnrelatedArgumentsAreIgnored() {
        // The old parser force-unwrapped `name:count` for every argument, so
        // any other argument crashed the app at launch.
        let arguments = UITestLaunchArguments(["-AppleLanguages", "(en)", "-flag:1", "Name:abc", "plain"])

        XCTAssertFalse(arguments.resetState)
        XCTAssertTrue(arguments.playlists.isEmpty)
    }
}
