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
        refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)
        //PlaylistPersistancyManager.sharedInstance.wipePlaylistCoreData(cntx: managedObjectContext)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists(cntx: managedObjectContext)
        tableView.reloadData()
        refreshControl.endRefreshing()
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
        let alert = createInsertPlaylistAlert()
        self.present(alert, animated: true, completion: nil)
    }
    
}
