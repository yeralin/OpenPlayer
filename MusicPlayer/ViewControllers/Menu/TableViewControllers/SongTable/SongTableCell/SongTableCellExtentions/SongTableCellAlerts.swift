//
//  SongTableCellAlerts.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongTableCellAlerts = SongTableCell
extension SongTableCellAlerts {
    
    func changeSongNameAlert() -> UIAlertController {
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
                if let typedArtist = textFields[self.ARTIST_TF_INDEX].text,
                   let typedTitle = textFields[self.TITLE_TF_INDEX].text {
                    do {
                        try SongPersistencyManager.sharedInstance.renameSong(song: self.song,
                                                                             newArtist: typedArtist,
                                                                             newTitle: typedTitle)
                        self.artistName.text = typedArtist
                        self.songTitle.text = typedTitle
                    } catch let err {
                        log.error("Could not rename \"\(self.song.songName ?? "unknown")\" song: \(err)")
                    }
                }
            }
            
        }))
        return alertChangeSongName
    }
}
