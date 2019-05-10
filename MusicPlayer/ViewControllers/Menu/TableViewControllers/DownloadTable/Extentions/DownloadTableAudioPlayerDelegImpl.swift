//
//  DownloadTableAudioPlayerDelegImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias DownloadTableAudioPlayerDelegImpl = DownloadTableViewController
extension DownloadTableAudioPlayerDelegImpl: StreamAudioPlayerDelegate {
    
    func initAudioPlayerDelegateImpl() {
        StreamAudioPlayer.sharedInstance.delegate = self
    }
    
    func cellState(state: PlayerState, song: DownloadSongEntity) {
        if let cell = getCell(withSong: song) {
            if state == .prepare {
                cell.prepareSongCellState()
            } else if state == .play {
                cell.playSongCellState()
            } else if state == .resume {
                cell.resumeSongCellState()
            } else if state == .pause {
                cell.pauseSongCellState()
            } else if state == .stop {
                cell.stopSongCellState()
            }
        }
    }
    
    func getSongArray() -> [DownloadSongEntity] {
        return searchSongs
    }
}
