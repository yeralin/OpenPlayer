//
//  AudioPlayerDelegateImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias AudioPlayerDelegateImpl = SongTableViewController
extension AudioPlayerDelegateImpl: AudioPlayerDelegate {
    
    func initAudioPlayerDelegateImpl() {
        AudioPlayer.sharedInstance.delegate = self
    }
    
    func cellState(state: State, song: SongEntity) {
        if let cell = getCell(withSong: song) {
            if state == State.play {
                cell.setPlaySongCell()
            } else if state == State.pause {
                cell.setPauseSongCell()
            } else if state == State.resume {
                cell.setPlaySongCell()
            } else if state == State.stop {
                cell.resetSongCell()
            } else {
                print("Error: should never happen")
            }
        }
    }
}
