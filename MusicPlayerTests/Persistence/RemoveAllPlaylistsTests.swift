//
//  RemoveAllPlaylistsTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class RemoveAllPlaylistsTests: PersistenceTestCase {

    func testRemovesFoldersAndRows() throws {
        _ = try persistence.makeSongs(["a - one.mp3"], inPlaylist: "First")
        try persistence.makePlaylist("Second")

        playlistManager.removeAllPlaylists()

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: persistence.documentsUrl.path), [])
        XCTAssertEqual(try persistence.fetchCount("PlaylistEntity"), 0)
        XCTAssertEqual(try persistence.fetchCount("SongEntity"), 0)
    }

    func testPlaylistsCanBeRecreatedAfterwards() throws {
        try persistence.makePlaylist("Test")

        playlistManager.removeAllPlaylists()

        // createPlaylist rejects names that still exist in Core Data.
        XCTAssertNoThrow(try playlistManager.createPlaylist(name: "Test"))
    }
}
