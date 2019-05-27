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

class SongTableViewController: UITableViewController {
    
    var playlist: PlaylistEntity!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var songTableView: UITableView!
    var songsArray: [SongEntity] = []
    var filteredSongs: [SongEntity] = []
    var searching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.playlistName
        navigationItem.rightBarButtonItem = self.editButtonItem
        songTableView.allowsSelection = false
        initDataSource()
    }
    
    func getCell(withSong song: SongEntity) -> SongCell? {
        let visibleSongCells = tableView.visibleCells as! [SongCell]
        if let index = visibleSongCells.firstIndex(where: { $0.song == song }) {
            return visibleSongCells[index]
        } else {
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PRESENT_PLAYLIST_PICKER {
            constructPicker(segue: segue, sender: sender)
        }
    }
}
