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
        if let index = visibleSongCells.firstIndex(where: { $0.song == song }) {
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
            do {
                guard let songToMove = sender as? SongEntity else {
                    throw "Could not unwrap sender as SongEntity"
                }
                guard let index = songsArray?.firstIndex(of: songToMove) else {
                    throw "Could not locate songToMove in songsArray"
                }
                pickerView.songToMove = songToMove
                var playlistArray = try PlaylistPersistencyManager.sharedInstance.getPlaylistArray()
                let currentPlaylistIndex = playlistArray.firstIndex(of: playlist)
                playlistArray.remove(at: currentPlaylistIndex!)
                pickerView.playlistArray = playlistArray
                songsArray?.remove(at: index)
            } catch let err {
                log.error("Could not move \"\((sender as? SongEntity)?.songName ?? "unknown")\" song: \(err)")
            }
        }
    }
}
