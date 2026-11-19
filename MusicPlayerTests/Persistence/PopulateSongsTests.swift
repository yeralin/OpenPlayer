//
//  PopulateSongsTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class PopulateSongsTests: PersistenceTestCase {

    private func songNames(afterAdding files: [String], folders: [String] = []) throws -> Set<String> {
        let playlist = try persistence.makePlaylist("Test", songFiles: files)
        let folder = persistence.documentsUrl.appendingPathComponent("Test")
        for name in folders {
            try FileManager.default.createDirectory(at: folder.appendingPathComponent(name),
                                                    withIntermediateDirectories: true)
        }
        return Set(try songManager.populateSongs(forPlaylist: playlist).compactMap(\.songName))
    }

    func testAudioFilesBecomeSongs() throws {
        let audio = ["a.mp3", "b.m4a", "c.wav", "d.aiff", "e.aac"]

        XCTAssertEqual(try songNames(afterAdding: audio), Set(audio))
    }

    func testNonAudioFilesAndFoldersAreIgnored() throws {
        let names = try songNames(afterAdding: ["song.mp3", "cover.jpg", "notes.txt", "README"],
                                  folders: ["Extras"])

        XCTAssertEqual(names, ["song.mp3"])
    }

    func testSongsWhoseFileWasRemovedAreDropped() throws {
        let playlist = try persistence.makePlaylist("Test", songFiles: ["keep.mp3", "gone.mp3"])
        _ = try songManager.populateSongs(forPlaylist: playlist)
        try FileManager.default.removeItem(
            at: persistence.documentsUrl.appendingPathComponent("Test/gone.mp3"))

        let songs = try songManager.populateSongs(forPlaylist: playlist)

        XCTAssertEqual(songs.compactMap(\.songName), ["keep.mp3"])
        XCTAssertEqual(try persistence.fetchCount("SongEntity"), 1)
    }
}
