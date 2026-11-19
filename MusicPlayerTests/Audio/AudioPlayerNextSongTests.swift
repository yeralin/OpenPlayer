//
//  AudioPlayerNextSongTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class AudioPlayerNextSongTests: AudioPlayerTestCase {

    func testNextAndPreviousWithNothingLoadedAreIgnored() {
        // Used to hit fatalError, e.g. pressing "next" on headphones after a stop.
        player.playNextSong(backward: false)
        player.playNextSong(backward: true)

        XCTAssertNil(player.currentSong)
        XCTAssertTrue(delegate.states.isEmpty)
        XCTAssertTrue(delegate.errors.isEmpty)
    }

    func testNextPlaysTheFollowingSong() throws {
        let songs = try makePlayableSongs(["a - one.mp3", "b - two.mp3"])
        try player.play(song: songs[0])

        player.playNextSong(backward: false)

        XCTAssertEqual(player.currentSong, songs[1])
        XCTAssertTrue(player.isPlaying())
    }

    func testPreviousPlaysTheSongBefore() throws {
        let songs = try makePlayableSongs(["a - one.mp3", "b - two.mp3"])
        try player.play(song: songs[1])

        player.playNextSong(backward: true)

        XCTAssertEqual(player.currentSong, songs[0])
    }

    func testNextOnTheLastSongStops() throws {
        let songs = try makePlayableSongs(["a - one.mp3"])
        try player.play(song: songs[0])

        player.playNextSong(backward: false)

        XCTAssertFalse(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .stop)
    }

    func testSongThatFailsToPlayIsReportedInsteadOfCrashing() throws {
        let songs = try makePlayableSongs(["a - one.mp3", "b - two.mp3"])
        // play(song:) rejects songs without artist/title metadata.
        songs[1].songArtist = nil
        try player.play(song: songs[0])

        player.playNextSong(backward: false)

        XCTAssertEqual(delegate.errors.count, 1)
        XCTAssertEqual(delegate.errors.first?.title, "Could not play the next song")
    }
}
