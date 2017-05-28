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
        return AudioPlayer.sharedInstance.songsArray.count
    }
    
    //Fill SongTable with SongCells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let AudioPlayerInst = AudioPlayer.sharedInstance
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        let song = AudioPlayerInst.songsArray[indexPath.row]
        cell.delegate = self
        //If there is a song that is playing inside a playlist, restore its view
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
            songPerstManager.deleteEntity(toDelete: song,
                                          cntx: managedObjectContext!)
            songsArray.remove(at: indexPath.row)
            //TODO: Can be optimized (reset order only after deleted song)
            AudioPlayer.sharedInstance.songsArray = songsArray.enumerated().map { (index, song) in
                song.songOrder = Int32(index)
                return song
            }
            songPerstManager.saveContext(cntx: managedObjectContext)
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
        songPerstManager.saveContext(cntx: managedObjectContext)
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
