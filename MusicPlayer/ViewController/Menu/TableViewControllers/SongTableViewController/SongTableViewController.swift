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
    var songsArray: [SongEntity]!
    var matchedSongs: [SongEntity]!
    var searching: Bool = false

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
        title = playlist.playlistName
        navigationItem.rightBarButtonItem = self.editButtonItem
        songTableView.allowsSelection = false
    }

    internal func getCell(withSong song: SongEntity) -> SongCell? {
        if let visibleSongCells = tableView.visibleCells as? [SongCell],
           let index = visibleSongCells.firstIndex(where: { $0.song == song }) {
            return visibleSongCells[index]
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.PRESENT_PLAYLIST_PICKER {
            guard let songCellToMove = sender as? BaseCell else {
                fatalError("Could not cast sender as SongCell")
            }
            constructPlaylistPicker(segue: segue, songCellToMove)
        }
    }
}
