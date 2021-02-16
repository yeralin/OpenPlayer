//
//  DownloadTableViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/25/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SWRevealViewController

class DownloadTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var downloadTableView: UITableView!
    var searchSongs: [SongEntity]! = []
    
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
        setupMenuGestureRecognizer()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        menuButton.target = self.revealViewController()
        downloadTableView.allowsSelection = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    public func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if revealController.frontViewPosition == FrontViewPosition.left {
            self.tableView.alwaysBounceVertical = true
            self.tableView.isScrollEnabled = true
            self.searchBar.isUserInteractionEnabled = true
        } else if revealController.frontViewPosition == FrontViewPosition.right {
            self.tableView.alwaysBounceVertical = false
            self.tableView.isScrollEnabled = false
            self.searchBar.isUserInteractionEnabled = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.PRESENT_PLAYLIST_PICKER {
            guard let songCellToMove = sender as? BaseCell else {
                fatalError("Could not cast sender as SongCell")
            }
            self.constructPlaylistPicker(segue: segue, songCellToMove)
        }
    }
    
}
