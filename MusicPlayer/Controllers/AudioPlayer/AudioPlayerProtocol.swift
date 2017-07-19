//
//  AudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/24/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

enum PlayerState {
    case prepare
    case play
    case pause
    case resume
    case stop
}

protocol AudioPlayerDelegate : class {
    func cellState(state: PlayerState, song: SongEntity)
    func getSongArray() -> [SongEntity]
}

protocol StreamAudioPlayerDelegate : class {
    func cellState(state: PlayerState, song: DownloadSongEntity)
    func getSongArray() -> [DownloadSongEntity]
}

protocol AudioPlayerProtocol {
    associatedtype PlayerType
    associatedtype SongEntityType
    associatedtype positionUnit
    var player : PlayerType! { get set }
    var currentSong: SongEntityType? { get set }
    var shuffleMode: Bool { get set }
        
    func playSong(song: SongEntityType)
    func resumeSong()
    func stopSong()
    func pauseSong()
    func seekTo(position: positionUnit)
    func playPreviousSong()
    func playNextSong()
    func getCurrentTimeAsString() -> String
    
    
    
}
