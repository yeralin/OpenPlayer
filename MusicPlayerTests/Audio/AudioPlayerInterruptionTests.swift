//
//  AudioPlayerInterruptionTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class AudioPlayerInterruptionTests: AudioPlayerTestCase {

    func testInterruptionWithNothingLoadedIsIgnored() {
        // Used to hit fatalError: pause()/resume() throw when no song is loaded.
        player.handleInterruption(notification: interruption(.began))
        player.handleInterruption(notification: interruption(.ended, options: .shouldResume))

        XCTAssertNil(player.currentSong)
        XCTAssertTrue(delegate.states.isEmpty)
    }

    func testInterruptionAfterStopIsIgnored() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)
        try player.play(song: song)
        try player.stop()
        let statesBefore = delegate.states.count

        player.handleInterruption(notification: interruption(.began))
        player.handleInterruption(notification: interruption(.ended, options: .shouldResume))

        XCTAssertFalse(player.isPlaying())
        XCTAssertEqual(delegate.states.count, statesBefore)
    }

    func testInterruptionPausesThenResumesWhenAllowed() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)
        try player.play(song: song)

        player.handleInterruption(notification: interruption(.began))
        XCTAssertFalse(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .pause)

        player.handleInterruption(notification: interruption(.ended, options: .shouldResume))
        XCTAssertTrue(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .resume)
    }

    func testInterruptionStaysPausedWhenResumeIsNotAllowed() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)
        try player.play(song: song)

        player.handleInterruption(notification: interruption(.began))
        player.handleInterruption(notification: interruption(.ended))

        XCTAssertFalse(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .pause)
    }
}
