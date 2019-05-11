//
//  PlaylistTableAlerts.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/30/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias PlaylistTableAlerts = PlaylistTableViewController
extension PlaylistTableAlerts {
    
    func insertPlaylist(playListName: String) {
        let playlistName = playListName
        if playlistName.isEmpty {return}
        do {
            let playlistPerstManager = PlaylistPersistencyManager.sharedInstance
            let newPosition: Int = try playlistPerstManager.createPlaylist(name: playlistName)
            self.playlistArray = try playlistPerstManager.getPlaylistArray()
            self.playlistTableView.insertRows(at: [IndexPath(row: newPosition, section: 0)],
                                              with: .fade)
        } catch let err {
            log.error("Could not insert a playlist \"\(playlistName)\": \(err)")
        }
    }
    
    func popCreatePlaylistAlert() throws -> UIAlertController {
        let alertNewPlaylist = UIAlertController(title: "Create new playlist", message: "Enter playlist name", preferredStyle: .alert)
        alertNewPlaylist.addTextField(configurationHandler: { textField in
            textField.placeholder = "Playlist Name"
        })
        guard let playListName = alertNewPlaylist.textFields?[0].text else {
            throw "Could not unwrap playlist name"
        }
        alertNewPlaylist.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertNewPlaylist.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) in self.insertPlaylist(playListName: playListName)}))
        return alertNewPlaylist
    }
    
    func createDeletePlaylistAlert(onComplete: @escaping (UIAlertAction) -> ()) -> UIAlertController {
        let alertDeleteConfirmation =
            UIAlertController(title: "Warning",
                              message: "Are you sure you want to delete this playlist with all songs in it?!",preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: onComplete)
        alertDeleteConfirmation.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertDeleteConfirmation.addAction(deleteAction)
        return alertDeleteConfirmation
    }
}
