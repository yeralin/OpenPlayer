//
//  DownloadTableCellDelegImpl
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 12/2/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//
import UIKit

private typealias DownloadTableCellDelegImpl = DownloadTableViewController
extension DownloadTableCellDelegImpl: SongCellDelegate {
    
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
