//
//  SongTableAudioPlayerDelegImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import UIKit
import SwiftOverlays

// MARK: Song table delegates implementation
extension SongTableViewController: AudioPlayerDelegate, CellToTableDelegate {

    internal func initAudioPlayerDelegateImpl() {
        AudioPlayer.instance.delegate = self
    }
    
    // MARK - CellToTableDelegateImpl
    func performSegueForCell(sender: Any?, identifier: String) {
        if identifier == Constants.PRESENT_PLAYLIST_PICKER {
            self.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    // MARK - AudioPlayerDelegateImpl
    
    func presentAlertForCell(alert: UIAlertController, alertName: String) {
        if alertName == Constants.PRESENT_CHANGE_SONG_NAME_ALERT {
            present(alert, animated: true, completion: nil)
        }
    }
    
    func getSongsArray(song: SongEntity) -> [SongEntity] {
        if let playlist = song.playlist {
            do {
                return try SongPersistencyManager.sharedInstance.getSongsArray(playlist: playlist)
            } catch let error {
                present(popUIErrorAlert(title: "Could not retrieve songs",
                                        reason: error.localizedDescription),
                        animated: true)
            }
        }
        return []
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
            log.info("SongCell is not visible, nothing to do")
            return
        }
        switch state {
        case .play, .resume:
            cell.playSongCellState()
        case .pause:
            cell.pauseSongCellState()
        case .stop:
            cell.stopSongCellState()
        case .prepare:
            fatalError("This state should not have been executed")
        }
    }
    
    // MARK - Shared
    
    internal func propagateError(title: String, error: String) {
        present(popUIErrorAlert(title: "Could not retrieve songs", reason: error.localizedDescription),
                animated: true)
    }
}
