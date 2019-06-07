//
//  BaseAudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 12/2/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import MediaPlayer

enum PlayerState {
    case prepare
    case play
    case pause
    case resume
    case stop
}

protocol AudioPlayerDelegate : class {
    func cellState(state: PlayerState, song: LocalSongEntity)
}

extension AVPlayer {
    var isPlaying: Bool {
        get {
            return rate != 0 && error == nil
        }
    }
    var duration: CMTime {
        get {
            return self.currentItem!.duration
        }
    }
}

class BaseAudioPlayer: NSObject {

    var currentSong: SongEntity?
    var rc: RemoteControl?
    weak var delegate: AudioPlayerDelegate?
    var shuffleMode: Bool = false

    internal func initRemoteControl(
            resumeSong: @escaping () -> (),
            pauseSong: @escaping () -> (),
            playNextSong: @escaping () -> (),
            playPreviousSong: @escaping () -> ()) {
        rc = RemoteControl.init(resumeSong: resumeSong,
                pauseSong: pauseSong,
                playNextSong: playNextSong,
                playPreviousSong: playPreviousSong)
    }

    deinit {
        rc?.resetMPControls()
    }
}
