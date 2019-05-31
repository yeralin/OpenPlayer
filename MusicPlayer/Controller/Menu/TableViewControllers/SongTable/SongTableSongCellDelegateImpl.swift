//
//  SongTableCellToTableDelegateImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongTableCellToTableDelegateImpl = SongTableViewController

extension SongTableCellToTableDelegateImpl: CellToTableDelegate {
    
    func performSegueForCell(sender: Any?, identifier: String) {
        if identifier == Constants.PRESENT_PLAYLIST_PICKER {
            self.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    func presentAlertForCell(alert: UIAlertController, alertName: String) {
        if alertName == Constants.PRESENT_CHANGE_SONG_NAME_ALERT {
            present(alert, animated: true, completion: nil)
        }
    }
}
