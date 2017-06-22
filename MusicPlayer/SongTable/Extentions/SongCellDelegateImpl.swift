//
//  SongCellDelegateImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongCellDelegateImpl = SongTableViewController
extension SongCellDelegateImpl: SongCellDelegate {

    func performSegueForCell(sender: Any?, identifier: String) {
        performSegue(withIdentifier: identifier, sender: sender)
    }
    
    func presentAlertForCell(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pickerView = segue.destination as! MoveSongPickerViewController
        pickerView.delegate = self
        if let songToMove = sender as? SongEntity {
            pickerView.songToMove = songToMove
            var playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray()
            let currentPlaylistIndex = playlistArray.index(of: playlist)
            playlistArray.remove(at: currentPlaylistIndex!)
            pickerView.playlistArray = playlistArray
        }
    }
}
