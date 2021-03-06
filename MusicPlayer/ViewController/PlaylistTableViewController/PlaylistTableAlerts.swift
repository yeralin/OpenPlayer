//
//  PlaylistTableAlerts.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/30/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

// MARK: Playlist table alerts
extension PlaylistTableViewController {
    
    func popDeletePlaylistAlert(onComplete: @escaping (UIAlertAction) -> ()) -> UIAlertController {
        let alertDeleteConfirmation =
            UIAlertController(title: "Warning",
                              message: "Are you sure you want to delete this playlist with all songs in it?!",
                              preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: onComplete)
        alertDeleteConfirmation.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertDeleteConfirmation.addAction(deleteAction)
        return alertDeleteConfirmation
    }
    
    func popCreatePlaylistAlert() throws -> UIAlertController {
        let alertNewPlaylist = UIAlertController(title: "Create new playlist",
                                                 message: "Enter playlist name",
                                                 preferredStyle: .alert)
        alertNewPlaylist.addTextField(configurationHandler: { textField in
            textField.placeholder = "Playlist Name"
        })
        alertNewPlaylist.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertNewPlaylist.addAction(UIAlertAction(title: "OK", style: .default,
                                                 handler: { (_:UIAlertAction) in
            guard let playListName = alertNewPlaylist.textFields?[0].text else {
                log.error("Could not unwrap playlist name")
                return;
            }
            self.insertPlaylist(playListName: playListName)
        }))
        return alertNewPlaylist
    }
}
