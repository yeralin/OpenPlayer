//
//  SongTableDeletionTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class SongTableDeletionTests: SongTableTestCase {

    private let files = ["a - one.mp3", "b - two.mp3", "c - three.mp3"]

    /// A song table in a window with its rows laid out, so UIKit's
    /// consistency checks in `deleteRows` run as they do in the app.
    private func makeVisibleTable() throws -> SongTableViewController {
        let playlist = try persistence.makePlaylist("Test", songFiles: files)
        let table = try makeSongTable(for: playlist)
        show(table)
        table.tableView.layoutIfNeeded()
        return table
    }

    private func search(_ table: SongTableViewController, for text: String) {
        table.searchBar.text = text
        table.searchBar(table.searchBar, textDidChange: text)
        table.tableView.layoutIfNeeded()
    }

    private func delete(row: Int, in table: SongTableViewController) {
        table.tableView(table.tableView, commit: .delete, forRowAt: IndexPath(row: row, section: 0))
    }

    private func filesOnDisk() throws -> Set<String> {
        let folder = persistence.documentsUrl.appendingPathComponent("Test")
        return Set(try FileManager.default.contentsOfDirectory(atPath: folder.path))
    }

    func testDeletingWithoutSearchDeletesThatRow() throws {
        let table = try makeVisibleTable()
        let doomed = try XCTUnwrap(table.songsArray[1].songName)

        delete(row: 1, in: table)

        XCTAssertEqual(try filesOnDisk(), Set(files).subtracting([doomed]))
        XCTAssertEqual(table.songsArray.count, 2)
    }

    func testDeletingWhileSearchingDeletesTheFilteredRow() throws {
        let table = try makeVisibleTable()
        search(table, for: "three")
        XCTAssertEqual(table.matchedSongs.map(\.songName), ["c - three.mp3"])

        // Row 0 of the filtered list. The old code deleted row 0 of the full
        // list (a different song, file included) and then UIKit raised
        // because the filtered row count had not changed.
        delete(row: 0, in: table)

        XCTAssertEqual(try filesOnDisk(), ["a - one.mp3", "b - two.mp3"])
        XCTAssertEqual(Set(table.songsArray.compactMap(\.songName)), ["a - one.mp3", "b - two.mp3"])
        XCTAssertTrue(table.matchedSongs.isEmpty)
        XCTAssertEqual(table.tableView.numberOfRows(inSection: 0), 0)
    }
}
