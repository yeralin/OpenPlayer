//
//  SongTableReorderTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class SongTableReorderTests: SongTableTestCase {

    private func makeTable() throws -> SongTableViewController {
        let playlist = try persistence.makePlaylist("Test", songFiles: ["a - one.mp3", "b - two.mp3", "c - three.mp3"])
        return try makeSongTable(for: playlist)
    }

    private func canMove(_ table: SongTableViewController, row: Int) -> Bool {
        table.tableView(table.tableView, canMoveRowAt: IndexPath(row: row, section: 0))
    }

    func testRowsCanBeReorderedWithoutSearch() throws {
        let table = try makeTable()
        let names = table.songsArray.map(\.songName)

        XCTAssertTrue(canMove(table, row: 0))
        table.tableView(table.tableView, moveRowAt: IndexPath(row: 0, section: 0), to: IndexPath(row: 2, section: 0))

        XCTAssertEqual(table.songsArray.map(\.songName), [names[1], names[2], names[0]])
        XCTAssertEqual(table.songsArray.map(\.songOrder), [0, 1, 2])
    }

    func testRowsCannotBeReorderedWhileSearching() throws {
        let table = try makeTable()
        table.searchBar.text = "o"
        table.searchBar(table.searchBar, textDidChange: "o")

        // moveRowAt indexes the full playlist, so dragging filtered rows used
        // to reorder unrelated songs.
        XCTAssertFalse(canMove(table, row: 0))

        table.searchBar.text = ""
        table.searchBar(table.searchBar, textDidChange: "")
        XCTAssertTrue(canMove(table, row: 0))
    }
}
