//
//  AudioPlayerTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class AudioPlayerTests: AudioPlayerTestCase {

    func testPlayLocalSongStartsPlaybackAndReportsPlay() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)

        try player.play(song: song)

        XCTAssertTrue(player.isPlaying())
        XCTAssertTrue(player.isPlaying(song: song))
        XCTAssertEqual(player.currentSong, song)
        XCTAssertEqual(delegate.lastState, .play)
    }

    func testPauseAndResume() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)
        try player.play(song: song)

        try player.pause()
        XCTAssertFalse(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .pause)

        try player.resume()
        XCTAssertTrue(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .resume)
    }

    func testStopReleasesThePlayer() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)
        try player.play(song: song)

        try player.stop()

        XCTAssertFalse(player.isPlaying(song: song))
        XCTAssertNil(player.duration())
        XCTAssertEqual(delegate.lastState, .stop)
    }

    func testPauseWithNothingLoadedThrows() {
        XCTAssertThrowsError(try player.pause())
        XCTAssertThrowsError(try player.resume())
        XCTAssertThrowsError(try player.stop())
    }
}
