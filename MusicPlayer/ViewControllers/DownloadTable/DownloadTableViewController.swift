//
//  DownloadTableViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/25/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SWRevealViewController

struct DownloadSongEntity {
    var songTitle: String?
    var songArtist: String?
    var songName: String?
    var songUrl: URL?
    static func == (left: DownloadSongEntity, right: DownloadSongEntity) -> Bool {
        let titleEq = (left.songTitle == right.songTitle)
        let artistEq = (left.songArtist == right.songArtist)
        let urlEq = (left.songUrl == right.songUrl)
        return titleEq && artistEq && urlEq
    }
}

class DownloadTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var downloadTableView: UITableView!
    var searchSongs: [DownloadSongEntity]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Download"
        setupMenuGestureRecognizer()
        initAudioPlayerDelegateImpl()
        menuButton.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: .systemColor,
                           cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                           target: self.revealViewController(),
                           action: #selector(SWRevealViewController.revealToggle(_:)))
        downloadTableView.allowsSelection = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func getCell(withSong song: DownloadSongEntity!) -> DownloadTableCell? {
        let visibleSongCells = tableView.visibleCells as! [DownloadTableCell]
        if let index = visibleSongCells.index(where: { $0.song == song }) {
            return visibleSongCells[index]
        } else {
            return nil
        }
    }
    
}
