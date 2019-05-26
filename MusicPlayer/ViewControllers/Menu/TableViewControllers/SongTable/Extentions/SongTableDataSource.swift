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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // How many SongCells to have
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredSongs!.count
        } else {
            return songsArray!.count
        }
    }
    
    //Fill SongTable with SongCells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let AudioPlayerInst = AudioPlayer.sharedInstance
        let song: SongEntity
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell",
                                                 for: indexPath) as! SongTableCell
        cell.delegate = self //For SongCellDelegate
        
        //If user is searching, get song from the filtered list
        if searching { song = filteredSongs![indexPath.row] }
        else { song = songsArray![indexPath.row] }
        
        if !song.isProcessed {
            do {
                try SongPersistencyManager.sharedInstance.processSong(toProcess: song)
            } catch let err {
                log.error("Could not rename \"\(song.songName ?? "unknown")\" song: \(err)")
            }
        }
        
        //If there is a song that's playing inside current playlist, restore its state view
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
            let songPerstManager = SongPersistencyManager.sharedInstance
            if let song = songsArray?[indexPath.row] {
                do {
                    try songPerstManager.deleteSong(song: song)
                    songsArray?.remove(at: indexPath.row)
                    try songPerstManager.saveContext()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch let err {
                    log.error("Could not delete \"\(song.songName ?? "unknown")\" song: \(err)")
                }
            }
            
        }
    }
    
    //  to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let songPerstManager = SongPersistencyManager.sharedInstance
        if let songToMove = songsArray?[fromIndexPath.row] {
            do {
                songsArray?.remove(at: fromIndexPath.row)
                songsArray?.insert(songToMove, at: to.row)
                // TODO: Can be optimized (reset order only after deleted song)
                songsArray = songsArray?.enumerated().map { (index, song) -> SongEntity in
                    song.songOrder = Int32(index)
                    return song
                }
                try songPerstManager.saveContext()
            } catch let err {
                log.error("Could not rearrange \"\(songToMove.songName ?? "unknown")\" song: \(err)")
            }
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
