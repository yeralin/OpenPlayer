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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pickerView = segue.destination as! MoveToPickerViewController
        pickerView.delegate = self
        if let songToMove = sender as? SongEntity {
            print(songToMove.songName!)
            print(songToMove.songOrder)
            pickerView.songToMove = songToMove
            var playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: managedObjectContext)
            let currentPlaylistIndex = playlistArray.index(of: playlist)
            playlistArray.remove(at: currentPlaylistIndex!)
            pickerView.playlistArray = playlistArray
        }
    }
    
    func presentAlertForCell(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }


}
