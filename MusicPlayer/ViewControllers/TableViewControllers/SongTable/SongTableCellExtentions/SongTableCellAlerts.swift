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
            let songArtist = alertChangeSongName.textFields![0].text!
            let songTitle = alertChangeSongName.textFields![1].text!
            if !songArtist.isEmpty && !songTitle.isEmpty {
                self.song.songArtist = songArtist
                self.song.songTitle = songTitle
                self.artistName.text = self.song.songArtist
                self.songTitle.text = self.song.songTitle
                SongPersistancyManager.sharedInstance.saveContext(cntx:
                    (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            }
            
        }))
        return alertChangeSongName
    }
}
