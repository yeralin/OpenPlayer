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
    
    //How many SongCells to have
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
           return filteredSongs!.count
        } else {
            return AudioPlayer.sharedInstance.songsArray.count
        }
    }
    
    //Fill SongTable with SongCells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let AudioPlayerInst = AudioPlayer.sharedInstance
        let song: SongEntity
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell",
                                                 for: indexPath) as! SongTableCell
        cell.delegate = self //For SongCellDelegate
        
        //If user is searching, get song from filtered list
        if searching { song = filteredSongs![indexPath.row] }
        else { song = AudioPlayerInst.songsArray[indexPath.row] }
        
        //If song is not processed (parsed metadata)
        if !song.isProcessed {
            SongPersistancyManager.sharedInstance.processSong(toProcess: song)
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let songPerstManager = SongPersistancyManager.sharedInstance
            var songsArray = AudioPlayer.sharedInstance.songsArray
            let song = songsArray[indexPath.row]
            songPerstManager.deleteEntity(toDelete: song)
            songsArray.remove(at: indexPath.row)
            //TODO: Can be optimized (reset order only after deleted song)
            AudioPlayer.sharedInstance.songsArray = songsArray.enumerated().map { (index, song) in
                song.songOrder = Int32(index)
                return song
            }
            songPerstManager.saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    //  to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let songPerstManager = SongPersistancyManager.sharedInstance
        var songsArray = AudioPlayer.sharedInstance.songsArray
        let songToMove = songsArray[fromIndexPath.row]
        songsArray.remove(at: fromIndexPath.row)
        songsArray.insert(songToMove, at: to.row)
        //TODO: Can be optimized (reset order only after deleted song)
        AudioPlayer.sharedInstance.songsArray = songsArray.enumerated().map { (index, song) in
            song.songOrder = Int32(index)
            return song
        }
        songPerstManager.saveContext()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
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
