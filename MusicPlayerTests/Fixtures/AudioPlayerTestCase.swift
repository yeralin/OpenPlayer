//
//  AudioPlayerTestCase.swift
//  MusicPlayerTests
//

import AVFoundation
import XCTest
@testable import MusicPlayer

/// Records what an `AudioPlayer` reports to its delegate.
final class RecordingAudioPlayerDelegate: AudioPlayerDelegate {

    /// Returned from `getSongsArray(song:)`, i.e. the "playlist" for next/previous.
    var songsArray: [SongEntity] = []
    private(set) var states: [(state: PlayerState, song: SongEntity)] = []
    private(set) var errors: [(title: String, error: String)] = []

    var lastState: PlayerState? { states.last?.state }

    func getSongsArray(song: SongEntity) -> [SongEntity] { songsArray }
    func cellState(state: PlayerState, song: SongEntity) { states.append((state, song)) }
    func propagateError(title: String, error: String) { errors.append((title, error)) }
}

/// Base class for tests that drive a real `AudioPlayer` with local files.
///
/// Each test gets a fresh `AudioPlayer` (not the app's shared instance) and a
/// recording delegate. Songs come from `PersistenceTestCase`'s temporary
/// Documents folder, so playback reads the bundled silent test mp3.
class AudioPlayerTestCase: PersistenceTestCase {

    var player: AudioPlayer!
    var delegate: RecordingAudioPlayerDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        delegate = RecordingAudioPlayerDelegate()
        player = AudioPlayer()
        player.delegate = delegate
    }

    override func tearDownWithError() throws {
        try? player?.stop() // Nothing may be loaded.
        player = nil
        delegate = nil
        try super.tearDownWithError()
    }

    /// Songs in a new playlist, with artist/title filled in so `play(song:)`
    /// accepts them. Also used as the delegate's songs array.
    func makePlayableSongs(_ files: [String]) throws -> [SongEntity] {
        let songs = try persistence.makeSongs(files)
        for song in songs {
            try songManager.processSong(toProcess: song)
        }
        delegate.songsArray = songs
        return songs
    }

    func interruption(_ type: AVAudioSession.InterruptionType,
                      options: AVAudioSession.InterruptionOptions = []) -> Notification {
        var userInfo: [AnyHashable: Any] = [AVAudioSessionInterruptionTypeKey: type.rawValue]
        if type == .ended {
            userInfo[AVAudioSessionInterruptionOptionKey] = options.rawValue
        }
        return Notification(name: AVAudioSession.interruptionNotification, object: nil, userInfo: userInfo)
    }
}
