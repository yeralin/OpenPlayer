//
//  PlaylistController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIcons
import CoreData

class PlaylistTableViewController: UITableViewController {
    
    @IBOutlet var playlistTableView: UITableView!
    lazy var managedObjectContext: NSManagedObjectContext! = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    var playlistArray: [PlaylistEntity]!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlists"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        menuButton.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: systemColor)
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists(cntx: managedObjectContext)
        //PlaylistPersistancyManager.sharedInstance.wipePlaylistCoreData(cntx: managedObjectContext)
    }
    
    
    
    @IBAction func openMenu(_ sender: Any) {
        if let slideMenuController = self.slideMenuController() {
            if slideMenuController.isLeftOpen() {
                slideMenuController.closeLeft()
            } else {
                slideMenuController.openLeft()
            }
        }
        
    }
    
    @IBAction func insertNewPlaylist(_ sender: Any) {
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
        self.present(alertNewPlaylist, animated: true, completion: nil)
    }
    
}
