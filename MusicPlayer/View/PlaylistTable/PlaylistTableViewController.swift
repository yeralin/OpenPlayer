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

extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}

class PlaylistTableViewController: UITableViewController {
    
    @IBOutlet var playlistTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var playlistArray: [PlaylistEntity]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initDataSource()
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.initDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlists"
        setupMenuGestureRecognizer()
        setupMenuButton(button: menuButton)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        refreshControl?.addTarget(self,
                                  action: #selector(self.handleRefresh(refreshControl:)),
                                  for: .valueChanged)
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
    
    @IBAction func insertNewPlaylist(_ sender: Any) {
        do {
            let alert = try popCreatePlaylistAlert()
            self.present(alert, animated: true, completion: nil)
        } catch let error {
            log.error("Could not construct playlist creation alert: \(error)")
        }
    }
    
}
