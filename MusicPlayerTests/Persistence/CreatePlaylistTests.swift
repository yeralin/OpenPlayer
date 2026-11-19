//
//  CreatePlaylistTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class CreatePlaylistTests: PersistenceTestCase {

    private func assertAlreadyExists(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try playlistManager.createPlaylist(name: name), file: file, line: line) { error in
            guard case UIError.AlreadyExists = error else {
                return XCTFail("Expected UIError.AlreadyExists, got \(error)", file: file, line: line)
            }
        }
    }

    func testNamesWithRegexCharactersAreAccepted() throws {
        // Each of these raised an Objective-C exception (crash) with MATCHES.
        for name in ["Mix [2024", "Best of (live", "C++", "What?", "*"] {
            let playlist = try playlistManager.createPlaylist(name: name)
            XCTAssertEqual(playlist.playlistName, name)
        }
        XCTAssertEqual(try persistence.fetchCount("PlaylistEntity"), 5)
    }

    func testDuplicateNamesAreRejectedIgnoringCaseAndDiacritics() throws {
        try playlistManager.createPlaylist(name: "Café")

        assertAlreadyExists("Café")
        assertAlreadyExists("café")
        assertAlreadyExists("CAFE")
    }

    func testANameIsNotTreatedAsAPattern() throws {
        // With MATCHES, "Rock.*" matched the existing "Rock and Roll".
        try playlistManager.createPlaylist(name: "Rock and Roll")

        XCTAssertNoThrow(try playlistManager.createPlaylist(name: "Rock.*"))
    }
}
