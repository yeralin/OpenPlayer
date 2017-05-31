//
//  InsertPlaylistAlert.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/30/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias InsertPlaylistAlert = PlaylistTableViewController
extension InsertPlaylistAlert {
    
    func createInsertPlaylistAlert() -> UIAlertController {
        let alertNewPlaylist = UIAlertController(title: "Create new playlist", message: "Enter playlist name", preferredStyle: .alert)
        alertNewPlaylist.addTextField(configurationHandler: { textField in
            textField.placeholder = "Playlist Name"
        })
        alertNewPlaylist.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertNewPlaylist.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let playlistName = alertNewPlaylist.textFields![0].text!
            if !playlistName.isEmpty {
                let playlistPerstManager = PlaylistPersistancyManager.sharedInstance
                let nextOrder: Int32 = {
                    let next: Int32 = 1
                    let playlistArray = playlistPerstManager.fetchData(entityName: "PlaylistEntity",
                                                                       sortIn: NSSortDescriptor(key: "playlistOrder", ascending: true),
                                                                       predicate: nil,
                                                                       cntx: self.managedObjectContext) as! [PlaylistEntity]
                    if let playlistMaxOrder = playlistArray.max(by: {$0.playlistOrder < $1.playlistOrder})?.playlistOrder {
                        return playlistMaxOrder + next
                    } else {
                        return 0
                    }
                }()
                let newOrder: Int = playlistPerstManager.createPlaylist(name: playlistName,
                                                                        order: nextOrder,
                                                                        cntx: self.managedObjectContext)
                self.playlistArray = playlistPerstManager.getPlaylistArray(cntx: self.managedObjectContext)
                self.playlistTableView.insertRows(at: [IndexPath(row: newOrder, section: 0)],
                                                  with: .fade)
            }
            
        }))
        return alertNewPlaylist
    }
}
