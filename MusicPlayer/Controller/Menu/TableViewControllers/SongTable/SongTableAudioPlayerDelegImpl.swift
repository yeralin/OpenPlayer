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

    internal func initAudioPlayerDelegateImpl() {
        AudioPlayer.sharedInstance.delegate = self
    }

    internal func cellState(state: PlayerState, song: SongEntity) {
        if !song.isProcessed {
            do {
                try SongPersistencyManager.sharedInstance.processSong(toProcess: song)
            } catch let err {
                log.error("Could not process \"\(song.songName ?? "unknown")\" song: \(err)")
            }
        }
        guard let cell = self.getCell(withSong: song) else {
            fatalError("Could not get SongCell for \"\(song.songName ?? "unknown")\" song")
        }
        switch state {
        case .play, .resume:
            cell.playSongCellState()
        case .pause:
            cell.pauseSongCellState()
        case .stop:
            cell.stopSongCellState()
        default:
            fatalError("State is not supported")
        }
    }
}
