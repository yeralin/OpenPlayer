//
//  File.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongTableViewDataSource = SongTableViewController
extension SongTableViewDataSource {
    
    func initDataSource() {
        initAudioPlayerDelegateImpl()
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
    
    func constructPicker(segue: UIStoryboardSegue, sender: Any?) {
        do {
            guard let pickerView = segue.destination as? PlaylistPickerViewController else {
                throw "Could not cast sender as SongEntity"
            }
            pickerView.delegate = self
            guard let songToMove = sender as? SongEntity else {
                throw "Could not cast sender as SongEntity"
            }
            pickerView.songToMove = songToMove
            var playlistArray = try PlaylistPersistencyManager.sharedInstance.getPlaylistArray()
            guard let currentPlaylistIndex = playlistArray.firstIndex(of: playlist) else {
                throw "Could not locate playlist in playlistArray"
            }
            playlistArray.remove(at: currentPlaylistIndex)
            pickerView.playlistArray = playlistArray
        } catch let err {
            log.error("Could not move \"\((sender as? SongEntity)?.songName ?? "unknown")\" song: \(err)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // How many SongCells to have
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredSongs.count
        } else {
            return songsArray.count
        }
    }
    
    // Fill SongTable with SongCells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let AudioPlayerInst = AudioPlayer.sharedInstance
        let song: SongEntity
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell",
                                                 for: indexPath) as! SongCell
        cell.delegate = self // For SongCellDelegate
        // If user is searching, get song from the filtered list
        if searching { song = filteredSongs[indexPath.row] }
        else { song = songsArray[indexPath.row] }
        if !song.isProcessed {
            do {
                try SongPersistencyManager.sharedInstance.processSong(toProcess: song)
            } catch let err {
                log.error("Could not rename \"\(song.songName ?? "unknown")\" song: \(err)")
            }
        }
        // If there is a song that's playing inside current playlist, restore its state view
        if AudioPlayerInst.player != nil
            && AudioPlayerInst.currentSong == song {
            cell.restorePlayingCell(song: AudioPlayerInst.currentSong!)
        } else {
            cell.initCell(initSong: song)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = songsArray[indexPath.row]
            do {
                let songPerstManager = SongPersistencyManager.sharedInstance
                try songPerstManager.deleteSong(song: song)
                var songsArray = try songPerstManager.getSongArray(playlist: self.playlist)
                songsArray = try songPerstManager.resetSongOrder(songArray: songsArray)
                try songPerstManager.saveContext()
                self.songsArray = songsArray
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let err {
                log.error("Could not delete \"\(song.songName ?? "unknown")\" song: \(err)")
            }
            
        }
    }
    
    // support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let songPerstManager = SongPersistencyManager.sharedInstance
        let songToMove = songsArray[fromIndexPath.row]
        do {
            songsArray.remove(at: fromIndexPath.row)
            songsArray.insert(songToMove, at: to.row)
            // TODO: Can be optimized (reset order only after deleted song)
            songsArray = songsArray.enumerated().map { (index, song) -> SongEntity in
                song.songOrder = Int32(index)
                return song
            }
            try songPerstManager.saveContext()
        } catch let err {
            log.error("Could not rearrange \"\(songToMove.songName ?? "unknown")\" song: \(err)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}