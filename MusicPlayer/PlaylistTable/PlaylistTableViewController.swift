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
    lazy var managedObjectContext: NSManagedObjectContext! = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    var playlistArray: [PlaylistEntity]!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlists"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        menuButton.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: .systemColor,
                           cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                           target: self.revealViewController(),
                           action: #selector(SWRevealViewController.revealToggle(_:)))
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists(cntx: managedObjectContext)
        refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)
        //PlaylistPersistancyManager.sharedInstance.wipePlaylistCoreData(cntx: managedObjectContext)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        playlistArray = PlaylistPersistancyManager.sharedInstance.populatePlaylists(cntx: managedObjectContext)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func insertNewPlaylist(_ sender: Any) {
        let alert = createInsertPlaylistAlert()
        self.present(alert, animated: true, completion: nil)
    }
    
}
