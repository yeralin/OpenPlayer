//
//  SongCellAlerts.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

// MARK: Song cell alerts
extension SongCell {

    internal func changeSongNameAlert() -> UIAlertController {
        let alertChangeSongName = UIAlertController(title: "Change the song name", message: nil, preferredStyle: .alert)
        alertChangeSongName.addTextField(configurationHandler: { textField in
            textField.text = self.song.songArtist
        })
        alertChangeSongName.addTextField(configurationHandler: { textField in
            textField.text = self.song.songTitle
        })
        alertChangeSongName.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertChangeSongName.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) -> Void in
            if let textFields = alertChangeSongName.textFields {
                if let typedArtist = textFields[self.ARTIST_TEXT_FIELD_INDEX].text,
                   let typedTitle = textFields[self.TITLE_TEXT_FIELD_INDEX].text {
                    self.handleChangeSongNameAlert(newArtist: typedArtist, newTitle: typedTitle)
                }
            }
        }))
        return alertChangeSongName
    }
    
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
