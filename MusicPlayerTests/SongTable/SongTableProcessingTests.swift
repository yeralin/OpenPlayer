//
//  SongTableProcessingTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class SongTableProcessingTests: SongTableTestCase {

    func testRowForASongThatCannotBeProcessedStillRenders() throws {
        let playlist = try persistence.makePlaylist("Test", songFiles: ["a - one.mp3", "b - two.mp3"])
        let table = try makeSongTable(for: playlist)
        let broken = try XCTUnwrap(table.songsArray.first)
        // processSong throws when the song's file path cannot be built.
        broken.playlist = nil

        // Used to hit fatalError and take the whole table down.
        let row = try XCTUnwrap(cell(table, row: 0))

        XCTAssertEqual(row.song, broken)
        XCTAssertFalse(broken.isProcessed, "Left unprocessed so it is retried later")
        XCTAssertNotNil(cell(table, row: 1), "Other rows are unaffected")
    }
}
