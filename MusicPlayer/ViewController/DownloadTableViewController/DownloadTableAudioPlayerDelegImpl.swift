//
//  DownloadTableAudioPlayerDelegImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import UIKit
import SwiftOverlays

// MARK: Download table audio player delegate implementation
extension DownloadTableViewController: AudioPlayerDelegate {
    
    internal func initAudioPlayerDelegateImpl() {
        // TODO: Refactor, rethink delegation assignment in player impls
        AudioPlayer.instance.delegate = self
    }
    
    func getSongsArray(song: SongEntity) -> [SongEntity] {
        return searchSongs
    }
    
    internal func propagateError(title: String, error: String) {
        let alert = UIAlertController(title: title,
                                      message: error,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    internal func cellState(state: PlayerState, song: SongEntity) {
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
    
    func getSongArray() -> [SongEntity] {
        return searchSongs
    }
}
