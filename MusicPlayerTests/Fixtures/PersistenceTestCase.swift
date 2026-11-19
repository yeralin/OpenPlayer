//
//  PersistenceTestCase.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

/// Base class for tests that touch playlists, songs or the file system.
/// Every test gets its own empty Documents folder and in-memory store.
class PersistenceTestCase: XCTestCase {

    var persistence: TestPersistence!

    var playlistManager: PlaylistPersistencyManager { .sharedInstance }
    var songManager: SongPersistencyManager { .sharedInstance }

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistence = try TestPersistence()
    }

    override func tearDownWithError() throws {
        persistence?.tearDown()
        persistence = nil
        try super.tearDownWithError()
    }
}
