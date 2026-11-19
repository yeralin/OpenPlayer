//
//  MPControlToggleTests.swift
//  MusicPlayerTests
//

import MediaPlayer
import XCTest
@testable import MusicPlayer

final class MPControlToggleTests: XCTestCase {

    private var calls: [String] = []

    private func toggle(isPlaying: Bool, resumeThrows: Bool = false) -> MPRemoteCommandHandlerStatus {
        MPControl.togglePlayPause(
            isPlaying: { isPlaying },
            resumeSong: {
                self.calls.append("resume")
                if resumeThrows { throw "Could not locate currentSong, nothing to resume" }
            },
            pauseSong: { self.calls.append("pause") })
    }

    func testTogglePausesWhilePlaying() {
        XCTAssertEqual(toggle(isPlaying: true), .success)
        XCTAssertEqual(calls, ["pause"])
    }

    func testToggleResumesWhilePaused() {
        // Used to pause unconditionally, so a paused song could not be
        // resumed from headphones or the lock screen's toggle.
        XCTAssertEqual(toggle(isPlaying: false), .success)
        XCTAssertEqual(calls, ["resume"])
    }

    func testToggleReportsFailureWhenNothingCanResume() {
        XCTAssertEqual(toggle(isPlaying: false, resumeThrows: true), .commandFailed)
    }
}

/// End to end through AudioPlayer's own isPlaying()/pause()/resume().
final class AudioPlayerToggleTests: AudioPlayerTestCase {

    private func toggle() -> MPRemoteCommandHandlerStatus {
        MPControl.togglePlayPause(isPlaying: player.isPlaying,
                                  resumeSong: player.resume,
                                  pauseSong: player.pause)
    }

    func testToggleAlternatesBetweenPauseAndResume() throws {
        let song = try XCTUnwrap(makePlayableSongs(["a - one.mp3"]).first)
        try player.play(song: song)

        XCTAssertEqual(toggle(), .success)
        XCTAssertFalse(player.isPlaying())

        XCTAssertEqual(toggle(), .success)
        XCTAssertTrue(player.isPlaying())
    }

    func testToggleWithNothingLoadedFails() {
        XCTAssertEqual(toggle(), .commandFailed)
    }
}
