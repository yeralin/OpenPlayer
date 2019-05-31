//
//  SongCellAlerts.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongCellAlerts = SongCell
extension SongCellAlerts {

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
}
