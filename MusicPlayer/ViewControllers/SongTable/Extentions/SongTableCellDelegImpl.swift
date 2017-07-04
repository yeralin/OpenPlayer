//
//  SongTableCellDelegImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongTableCellDelegImpl = SongTableViewController
extension SongTableCellDelegImpl: SongCellDelegate {
    
    func performSegueForCell(sender: Any?, identifier: String) {
        if identifier == "showPlaylistPicker" {
            performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    func presentAlertForCell(alert: UIAlertController, alertName: String) {
        if alertName == "presentChangeSongNameAlert" {
            present(alert, animated: true, completion: nil)
        }
    }
}
