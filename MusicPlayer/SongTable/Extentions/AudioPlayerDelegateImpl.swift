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
        if !song.isProcessed {
            SongPersistancyManager.sharedInstance.processSong(toProcess: song)
        }
        if let cell = getCell(withSong: song) {
            if !song.isProcessed {
                log.info("Processing \(song.songName!)")
                SongPersistancyManager.sharedInstance.processSong(toProcess: song)
            }
            if state == .play || state == .resume {
                cell.setPlaySongCell()
            } else if state == .pause {
                cell.setPauseSongCell()
            } else if state == .stop {
                cell.resetSongCell()
            }
        }
    }
}
