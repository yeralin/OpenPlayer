//
//  DownloadTableDataSource.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/25/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import UIKit

// MARK: Download table data source
extension DownloadTableViewController {
    
    internal func initDataSource() {
        initAudioPlayerDelegateImpl()
    }
    
    internal func getCell(withSong song: SongEntity!) -> DownloadCell? {
        let visibleSongCells = tableView.visibleCells as! [DownloadCell]
        if let index = visibleSongCells.firstIndex(where: { $0.song == song }) {
            return visibleSongCells[index]
        }
        return nil
    }
    
    internal func constructPlaylistPicker(segue: UIStoryboardSegue, _ songCellToMove: BaseCell) {
        do {
            guard let pickerView = segue.destination as? PlaylistPickerViewController else {
                throw "Could not cast sender as PlaylistPickerViewController"
            }
            let playlistArray = try PlaylistPersistencyManager.sharedInstance.getPlaylistArray()
            pickerView.delegate = self
            pickerView.songCellToMove = songCellToMove
            pickerView.playlistArray = playlistArray
        } catch let err {
            log.error("Could not construct \"moveSong\" picker for "
                        + "\(songCellToMove.song.songName ?? "unknown")\" song: \(err)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song: SongEntity = searchSongs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadSongCell",
                                                 for: indexPath) as! DownloadCell
        cell.delegate = self
        //If there is a song that's playing inside current playlist, restore its state view
        if let currentSong = AudioPlayer.instance.currentSong, currentSong == song {
            cell.restorePlayingCell(song: song)
        } else {
            cell.initCell(initSong: song)
        }
        return cell
    }
}
