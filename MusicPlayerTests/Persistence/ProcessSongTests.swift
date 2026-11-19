//
//  ProcessSongTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class ProcessSongTests: PersistenceTestCase {

    /// A processed song made from the test mp3, optionally ID3-tagged.
    private func processedSong(fileName: String, tags: [String: String] = [:]) throws -> SongEntity {
        let playlist = try persistence.makePlaylist("Test")
        let url = persistence.documentsUrl.appendingPathComponent("Test").appendingPathComponent(fileName)
        if tags.isEmpty {
            try FileManager.default.copyItem(at: TestPersistence.testSongUrl, to: url)
        } else {
            try ID3Tag.writeTaggedSong(to: url, frames: tags)
        }
        let song = try XCTUnwrap(songManager.populateSongs(forPlaylist: playlist).first)
        try songManager.processSong(toProcess: song)
        return song
    }

    func testUsesTitleAndArtistTags() throws {
        let song = try processedSong(fileName: "file - name.mp3",
                                     tags: ["TIT2": "Real Title", "TPE1": "Real Artist"])

        // The artist tag used to be written into songTitle, which then
        // fell back to parsing the file name for both fields.
        XCTAssertEqual(song.songArtist, "Real Artist")
        XCTAssertEqual(song.songTitle, "Real Title")
        XCTAssertTrue(song.isProcessed)
    }

    func testUntaggedFileFallsBackToArtistDashTitleFileName() throws {
        let song = try processedSong(fileName: "Some Artist - Some Title.mp3")

        XCTAssertEqual(song.songArtist, "Some Artist")
        XCTAssertEqual(song.songTitle, "Some Title")
    }

    func testFileNameWithoutDashBecomesTheArtist() throws {
        let song = try processedSong(fileName: "untitled.mp3")

        XCTAssertEqual(song.songArtist, "untitled")
        XCTAssertEqual(song.songTitle, "")
    }

    func testPartialTagsFallBackToTheFileName() throws {
        // Only a title tag: both fields come from the file name, as before.
        let song = try processedSong(fileName: "Some Artist - Some Title.mp3", tags: ["TIT2": "Tagged"])

        XCTAssertEqual(song.songArtist, "Some Artist")
        XCTAssertEqual(song.songTitle, "Some Title")
    }
}
