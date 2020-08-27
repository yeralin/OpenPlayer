//
//  File.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

// MARK: Song table data source
extension SongTableViewController {

    internal func initDataSource() {
        initAudioPlayerDelegateImpl()
    }

    func prepareSongs(targetPlaylist: PlaylistEntity) {
        do {
            playlist = targetPlaylist
            songsArray = try SongPersistencyManager.sharedInstance
                    .populateSongs(forPlaylist: playlist)
        } catch let err {
            log.error("Could not prepare songs: \(err)")
        }
    }

    internal func constructPlaylistPicker(segue: UIStoryboardSegue, sender: Any?) {
        do {
            guard let pickerView = segue.destination as? PlaylistPickerViewController else {
                throw "Could not cast sender as PlaylistPickerViewController"
            }
            guard let songToMove = sender as? SongEntity else {
                throw "Could not cast sender as SongEntity"
            }
            var playlistArray = try PlaylistPersistencyManager.sharedInstance.getPlaylistArray()
            guard let currentPlaylistIndex = playlistArray.firstIndex(of: playlist) else {
                throw "Could not locate playlist in playlistArray"
            }
            pickerView.delegate = self
            pickerView.songToMove = songToMove
            playlistArray.remove(at: currentPlaylistIndex)
            pickerView.playlistArray = playlistArray
        } catch let err {
            log.error("Could not construct \"moveSong\" picker for "
                      + "\"\((sender as? SongEntity)?.songName ?? "unknown")\" song: \(err)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.ONE_SECTION
    }

    // How many SongCells to render
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return matchedSongs.count
        } else {
            return songsArray.count
        }
    }
    
    // Fill SongTable with SongCells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song: SongEntity
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell",
                for: indexPath) as? SongCell else {
            fatalError("Could not dequeue SongCell")
        }
        // For SongCellDelegate
        cell.delegate = self
        // If user is searching, get a song from a filtered list
        if searching {
            song = matchedSongs[indexPath.row]
        }
        else { song = songsArray[indexPath.row] }
        if !song.isProcessed {
            do {
                try SongPersistencyManager.sharedInstance.processSong(toProcess: song)
            } catch let err {
                fatalError("Could not process \"\(song.songName ?? "unknown")\" song: \(err)")
            }
        }
        // If there is a song that's playing inside a current playlist, restore its state view
        if AudioPlayer.instance.isPlaying(song: song){
            cell.restorePlayingCell(song: song)
        } else {
            cell.initCell(initSong: song)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = songsArray[indexPath.row]
            if let currentSong = AudioPlayer.instance.currentSong,
               song == currentSong {
                // TODO: Stop song
            }
            do {
                let songPerstManager = SongPersistencyManager.sharedInstance
                try songPerstManager.deleteSong(song: song)
                var songsArray = try songPerstManager.getSongsArray(playlist: self.playlist)
                songsArray = try songPerstManager.resetSongOrder(songArray: songsArray)
                try songPerstManager.saveContext()
                self.songsArray = songsArray
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let err {
                log.error("Could not delete \"\(song.songName ?? "unknown")\" song: \(err)")
            }
        }
    }

    // Support rearranging the table view.
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
