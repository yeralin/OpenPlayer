//
//  DownloadTableCellDelegImpl
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 12/2/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//
import UIKit

// MARK: Download table cell delegate
extension DownloadTableViewController: CellToTableDelegate {
    
    func performSegueForCell(songCellToMove: BaseCell, identifier: String) {
        if identifier == Constants.PRESENT_PLAYLIST_PICKER {
            self.performSegue(withIdentifier: identifier, sender: songCellToMove)
        }
    }
    
    func presentAlertForCell(alert: UIAlertController, alertName: String) {
        if alertName == Constants.PRESENT_CHANGE_SONG_NAME_ALERT {
            present(alert, animated: true, completion: nil)
        }
    }
}
