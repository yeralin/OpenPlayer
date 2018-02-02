//
//  SongTableCellDelegImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

let PRESENT_PLAYLIST_PICKER = "presentPlaylistPicker"
let PRESENT_CHANGE_SONG_NAME_ALERT = "presentChangeSongNameAlert"

private typealias SongTableCellDelegImpl = SongTableViewController
extension SongTableCellDelegImpl: SongCellDelegate {
    
    func performSegueForCell(sender: Any?, identifier: String) {
        if identifier == PRESENT_PLAYLIST_PICKER {
            self.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    func presentAlertForCell(alert: UIAlertController, alertName: String) {
        if alertName == PRESENT_CHANGE_SONG_NAME_ALERT {
            present(alert, animated: true, completion: nil)
        }
    }
}
