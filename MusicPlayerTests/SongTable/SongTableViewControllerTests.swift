//
//  SongTableViewControllerTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class SongTableViewControllerTests: SongTableTestCase {

    private func search(_ table: SongTableViewController, for text: String) {
        table.searchBar.text = text
        table.searchBar(table.searchBar, textDidChange: text)
    }

    func testShowsOneRowPerSongWithArtistAndTitle() throws {
        let playlist = try persistence.makePlaylist("Test", songFiles: ["a - one.mp3", "b - two.mp3"])
        let table = try makeSongTable(for: playlist)

        XCTAssertEqual(table.title, "Test")
        XCTAssertEqual(table.tableView(table.tableView, numberOfRowsInSection: 0), 2)
        let first = try XCTUnwrap(cell(table, row: 0))
        XCTAssertEqual(first.artistName.text, first.song.songArtist)
        XCTAssertEqual(first.songTitle.text, first.song.songTitle)
    }

    func testSearchFiltersRowsBySongName() throws {
        let playlist = try persistence.makePlaylist("Test", songFiles: ["a - one.mp3", "b - two.mp3"])
        let table = try makeSongTable(for: playlist)

        search(table, for: "TWO")

        XCTAssertEqual(table.tableView(table.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(cell(table, row: 0)?.song.songName, "b - two.mp3")

        search(table, for: "")
        XCTAssertEqual(table.tableView(table.tableView, numberOfRowsInSection: 0), 2)
    }
}
