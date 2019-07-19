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

private typealias SongTableAudioPlayerDelegImpl = SongTableViewController
extension SongTableAudioPlayerDelegImpl: AudioPlayerDelegate {

    internal func initAudioPlayerDelegateImpl() {
        AudioPlayer.instance.delegate = self
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

    internal func
        cellState(state: PlayerState, song: SongEntity) {
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
}
