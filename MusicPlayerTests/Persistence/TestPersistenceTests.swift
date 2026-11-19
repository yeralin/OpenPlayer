//
//  TestPersistenceTests.swift
//  MusicPlayerTests
//
//  Checks the fixture itself, so later tests can rely on it.
//

import XCTest
@testable import MusicPlayer

final class TestPersistenceTests: PersistenceTestCase {

    func testPlaylistFolderIsCreatedInTemporaryDocuments() throws {
        try persistence.makePlaylist("Fixture")

        var isDirectory: ObjCBool = false
        let folder = persistence.documentsUrl.appendingPathComponent("Fixture").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: folder, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertEqual(try persistence.fetchCount("PlaylistEntity"), 1)
    }

    func testPopulateSongsFindsCopiedAudioFiles() throws {
        let songs = try persistence.makeSongs(["b - two.mp3", "a - one.mp3"])

        XCTAssertEqual(Set(songs.compactMap(\.songName)), ["a - one.mp3", "b - two.mp3"])
        XCTAssertEqual(songs.map(\.songOrder), [0, 1])
    }

    func testTearDownRestoresTheSharedManagers() throws {
        let fixtureDocs = persistence.documentsUrl
        let fixtureContext = persistence.context
        XCTAssertEqual(playlistManager.docsUrl, fixtureDocs)
        XCTAssertTrue(songManager.managedObjectContext === fixtureContext)

        persistence.tearDown()

        XCTAssertNotEqual(playlistManager.docsUrl, fixtureDocs)
        XCTAssertFalse(songManager.managedObjectContext === fixtureContext)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixtureDocs.path))
    }
}
