//
//  PlaylistController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIconFont
import CoreData

class PlaylistTableViewController: UITableViewController {
    
    @IBOutlet var playlistTableView: UITableView!
    lazy var managedObjectContext: NSManagedObjectContext! = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    var playlistArray: [PlaylistEntity]!
    
    
    @IBAction func openMenu(_ sender: Any) {
        if let slideMenuController = self.slideMenuController() {
            if slideMenuController.isLeftOpen() {
                slideMenuController.closeLeft()
            } else {
                slideMenuController.openLeft()
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlists"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists(cntx: managedObjectContext)
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
                let newOrder: Int = PlaylistPersistancyManager.sharedInstance.createPlaylist(name: playlistName, cntx: self.managedObjectContext)
                self.playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: self.managedObjectContext)
                self.playlistTableView.insertRows(at: [IndexPath(row: newOrder, section: 0)], with: .fade)
            }
            
        }))
        self.present(alertNewPlaylist, animated: true, completion: nil)
    }
    
}
