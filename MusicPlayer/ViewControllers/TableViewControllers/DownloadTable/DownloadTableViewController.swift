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
        setupMenuButton(button: menuButton)
        downloadTableView.allowsSelection = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        if let songsArray = StreamAudioPlayer.sharedInstance.songsArray {
            self.searchSongs = songsArray
        }
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
    
    func getCell(withSong song: DownloadSongEntity!) -> DownloadTableCell? {
        let visibleSongCells = tableView.visibleCells as! [DownloadTableCell]
        if let index = visibleSongCells.index(where: { $0.song == song }) {
            return visibleSongCells[index]
        } else {
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PRESENT_PLAYLIST_PICKER {
            let pickerView = segue.destination as! PlaylistPickerViewController
            pickerView.delegate = self
            if let songToDownload = sender as? DownloadSongEntity {
                pickerView.songToMove = songToDownload
                let playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray()
                //let currentPlaylistIndex = playlistArray.index(of: playlist)
                //playlistArray.remove(at: currentPlaylistIndex!)
                pickerView.playlistArray = playlistArray
            }
        }
    }
    
}
