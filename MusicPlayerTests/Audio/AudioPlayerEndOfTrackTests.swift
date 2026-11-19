//
//  AudioPlayerEndOfTrackTests.swift
//  MusicPlayerTests
//

import AVFoundation
import XCTest
@testable import MusicPlayer

final class AudioPlayerEndOfTrackTests: AudioPlayerTestCase {

    private func postDidPlayToEnd(_ item: AVPlayerItem?) {
        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: item)
    }

    func testEndOfTrackAdvancesForward() throws {
        let songs = try makePlayableSongs(["a - one.mp3", "b - two.mp3", "c - three.mp3"])
        try player.play(song: songs[1])

        postDidPlayToEnd(player.currentPlayerItem)

        XCTAssertEqual(player.currentSong, songs[2])
    }

    func testEndOfTheLastTrackStops() throws {
        let songs = try makePlayableSongs(["a - one.mp3", "b - two.mp3"])
        try player.play(song: songs[1])

        postDidPlayToEnd(player.currentPlayerItem)

        XCTAssertFalse(player.isPlaying())
        XCTAssertEqual(delegate.lastState, .stop)
    }

    func testEndOfAnotherItemIsIgnored() throws {
        let songs = try makePlayableSongs(["a - one.mp3", "b - two.mp3"])
        try player.play(song: songs[0])

        postDidPlayToEnd(AVPlayerItem(url: TestPersistence.testSongUrl))

        XCTAssertEqual(player.currentSong, songs[0])
    }
}
