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
        do {
            playlistArray = try PlaylistPersistencyManager.sharedInstance.populatePlaylists()
        } catch let err {
            fatalError("Could not populate playlists: \(err))")
        }
        refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)
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
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        do {
            playlistArray = try PlaylistPersistencyManager.sharedInstance.populatePlaylists()
            tableView.reloadData()
            refreshControl.endRefreshing()
        } catch let err {
            fatalError("Could not populate playlists: \(err))")
        }
    }
    
    @IBAction func insertNewPlaylist(_ sender: Any) {
        do {
            let alert = try popCreatePlaylistAlert()
            self.present(alert, animated: true, completion: nil)
        } catch let error {
            log.error("Could not construct playlist creation alert: \(error)")
        }
    }
    
}
