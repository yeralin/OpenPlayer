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
import SWRevealViewController

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var selectIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectIcon.setIcon(icon: .fontAwesome(.angleRight), iconSize: 28, color: .systemColor, forState: .normal)
    }
}

class PlaylistTableViewController: UITableViewController {
    
    @IBOutlet var playlistTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var playlistArray: [PlaylistEntity]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlists"
        setupMenuGestureRecognizer()
        setupMenuButton(button: menuButton)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)
        //PlaylistPersistancyManager.sharedInstance.wipePlaylistCoreData(cntx: managedObjectContext)
    }
    
    public func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if revealController.frontViewPosition == FrontViewPosition.left {
            self.tableView.alwaysBounceVertical = true
            self.tableView.allowsSelection = true
            
        } else if revealController.frontViewPosition == FrontViewPosition.right {
            self.tableView.alwaysBounceVertical = false
            self.tableView.allowsSelection = false
        }
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func insertNewPlaylist(_ sender: Any) {
        let alert = createInsertPlaylistAlert()
        self.present(alert, animated: true, completion: nil)
    }
    
}
