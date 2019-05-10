//
//  SongTableAudioPlayerDelegImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias SongTableAudioPlayerDelegImpl = SongTableViewController
extension SongTableAudioPlayerDelegImpl: AudioPlayerDelegate {

    func initAudioPlayerDelegateImpl() {
        AudioPlayer.sharedInstance.delegate = self
    }
    
    func cellState(state: PlayerState, song: SongEntity) {
        if !song.isProcessed {
            SongPersistancyManager.sharedInstance.processSong(toProcess: song)
        }
        if let cell = getCell(withSong: song) {
            if state == .play || state == .resume {
                cell.playSongCellState()
            } else if state == .pause {
                cell.pauseSongCellState()
            } else if state == .stop {
                cell.stopSongCellState()
            } else {
                log.error("State is not supported")
            }
        }
    }
}
