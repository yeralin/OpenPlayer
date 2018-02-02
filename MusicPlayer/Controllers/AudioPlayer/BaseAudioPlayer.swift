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
    func cellState(state: PlayerState, song: SongEntity)
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
    
}
