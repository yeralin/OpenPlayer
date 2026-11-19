//
//  SongTableErrorAlertTests.swift
//  MusicPlayerTests
//

import UIKit
import XCTest
@testable import MusicPlayer

final class SongTableErrorAlertTests: SongTableTestCase {

    private func presentedAlert(on controller: UIViewController) -> UIAlertController? {
        let presented = expectation(for: NSPredicate { _, _ in controller.presentedViewController != nil },
                                    evaluatedWith: nil)
        wait(for: [presented], timeout: 2)
        return controller.presentedViewController as? UIAlertController
    }

    func testErrorAlertShowsTheGivenTitleAndMessage() throws {
        let playlist = try persistence.makePlaylist("Test", songFiles: ["a - one.mp3"])
        let table = try makeSongTable(for: playlist)
        show(table)

        table.propagateError(title: "Audio player failed", error: "Could not locate currentSong")

        // The title used to be hard-coded to "Could not retrieve songs" for
        // every error, whatever had actually failed.
        let alert = try XCTUnwrap(presentedAlert(on: table))
        XCTAssertEqual(alert.title, "Audio player failed")
        XCTAssertEqual(alert.message, "Could not locate currentSong")
    }
}
