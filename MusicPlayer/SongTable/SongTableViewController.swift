//
//  songTableView.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/23/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class SongTableViewController: UITableViewController, UISearchBarDelegate {
    
    var playlist: PlaylistEntity!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var songTableView: UITableView!
    var filteredSongs: [SongEntity]?
    var searching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.playlistName
        navigationItem.rightBarButtonItem = self.editButtonItem
        songTableView.allowsSelection = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        initAudioPlayerDelegateImpl()
    }
    
    func getCell(withSong song: SongEntity) -> SongCell? {
        let visibleSongCells = tableView.visibleCells as! [SongCell]
        if let index = visibleSongCells.index(where: { el in el.song == song }) {
            return visibleSongCells[index]
        } else {
            return nil
        }
    }
    
    func prepareSongs(receivedPlaylist: PlaylistEntity) {
        playlist = receivedPlaylist
        let songsArray = SongPersistancyManager.sharedInstance
                            .populateSongs(forPlaylist: receivedPlaylist)
        AudioPlayer.sharedInstance.songsArray = songsArray
    }
    
}
