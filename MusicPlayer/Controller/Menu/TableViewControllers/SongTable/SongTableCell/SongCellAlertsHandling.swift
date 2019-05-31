//
//  SongCellAlertHandling.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/26/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias SongCellAlertsHandling = SongCell
extension SongCellAlertsHandling {

    internal func handleChangeSongNameAlert(newArtist: String, newTitle: String) {
        do {
            let songPerstManager = SongPersistencyManager.sharedInstance
            try songPerstManager.renameSong(song: self.song,
                                            newArtist: newArtist,
                                            newTitle: newTitle)
            self.artistName.text = newArtist
            self.songTitle.text = newTitle
        } catch let err {
            log.error("Could not rename \"\(self.song.songName ?? "unknown")\" song: \(err)")
        }
    }
}
