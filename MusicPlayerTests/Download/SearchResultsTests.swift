//
//  SearchResultsTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class SearchResultsTests: PersistenceTestCase {

    private var originalPlayerDelegate: AudioPlayerDelegate?

    override func setUpWithError() throws {
        try super.setUpWithError()
        originalPlayerDelegate = AudioPlayer.instance.delegate
    }

    override func tearDownWithError() throws {
        // DownloadTableViewController makes itself the shared player's delegate.
        AudioPlayer.instance.delegate = originalPlayerDelegate
        try super.tearDownWithError()
    }

    private let results = [
        SearchResultEntry(source: "test", title: "Artist One - Song One",
                          url: URL(string: "http://127.0.0.1:9/1.mp3")!),
        SearchResultEntry(source: "test", title: "Untitled",
                          url: URL(string: "http://127.0.0.1:9/2.mp3")!),
    ]

    func testSearchResultsAreNeverSaved() throws {
        let controller = DownloadTableViewController(style: .plain)
        controller.populateSongListResponse(results)
        XCTAssertEqual(controller.searchSongs.count, 2)

        // Any later save (renaming or reordering a song, for example) used to
        // write every search result into the store as a song without a playlist.
        try persistence.makePlaylist("Saved")
        try persistence.context.save()

        XCTAssertEqual(try persistence.fetchCount("SongEntity"), 0)
        XCTAssertTrue(controller.searchSongs.allSatisfy { $0.managedObjectContext == nil })
    }

    func testSearchResultsKeepTheirMetadata() throws {
        let controller = DownloadTableViewController(style: .plain)
        controller.populateSongListResponse(results)

        let first = controller.searchSongs[0]
        XCTAssertEqual(first.songArtist, "Artist One")
        XCTAssertEqual(first.songTitle, "Song One")
        XCTAssertEqual(first.songUrl, results[0].url)
        XCTAssertTrue(first.isRemote())

        let second = controller.searchSongs[1]
        XCTAssertEqual(second.songArtist, "")
        XCTAssertEqual(second.songTitle, "Untitled")
    }
}
