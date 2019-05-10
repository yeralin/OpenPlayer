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
    
    func createPlaylist(playListName: String) {
        let playlistName = playListName
        if playlistName.isEmpty {return}
        let playlistPerstManager = PlaylistPersistancyManager.sharedInstance
        let nextOrder: Int32 = {
            let next: Int32 = 1
            let playlistArray = playlistPerstManager.fetchData(entityName: "PlaylistEntity",
                                                               sortIn: NSSortDescriptor(key: "playlistOrder", ascending: true),
                                                               predicate: nil) as! [PlaylistEntity]
            if let playlistMaxOrder = playlistArray.max(by: {$0.playlistOrder < $1.playlistOrder})?.playlistOrder {
                return playlistMaxOrder + next
            } else {
                return 0
            }
        }()
        let newOrder: Int = playlistPerstManager.createPlaylist(name: playlistName,
                                                                order: nextOrder)
        self.playlistArray = playlistPerstManager.getPlaylistArray()
        self.playlistTableView.insertRows(at: [IndexPath(row: newOrder, section: 0)],
                                          with: .fade)
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
        alertNewPlaylist.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) in self.createPlaylist(playListName: playListName)}))
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
