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
    var songsArray: [SongEntity]?
    var filteredSongs: [SongEntity]?
    var searching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.playlistName
        navigationItem.rightBarButtonItem = self.editButtonItem
        songTableView.allowsSelection = false
        initAudioPlayerDelegateImpl()
    }
    
    func getCell(withSong song: SongEntity) -> SongTableCell? {
        let visibleSongCells = tableView.visibleCells as! [SongTableCell]
        if let index = visibleSongCells.index(where: { $0.song == song }) {
            return visibleSongCells[index]
        } else {
            return nil
        }
    }
    
    func prepareSongs(receivedPlaylist: PlaylistEntity) {
        do {
            playlist = receivedPlaylist
            songsArray = try SongPersistencyManager.sharedInstance
                                .populateSongs(forPlaylist: receivedPlaylist)
        } catch let err {
            log.error("Could not prepare songs: \(err)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PRESENT_PLAYLIST_PICKER {
            let pickerView = segue.destination as! PlaylistPickerViewController
            pickerView.delegate = self
            if let songToMove = sender as? SongEntity {
                do {
                    pickerView.songToMove = songToMove
                    var playlistArray = try PlaylistPersistencyManager.sharedInstance.getPlaylistArray()
                    let currentPlaylistIndex = playlistArray.index(of: playlist)
                    playlistArray.remove(at: currentPlaylistIndex!)
                    pickerView.playlistArray = playlistArray
                } catch let err {
                    log.error("Could not move \"\(songToMove.songName ?? "unknown")\" song: \(err)")
                }
            }
        }
    }
    
}
