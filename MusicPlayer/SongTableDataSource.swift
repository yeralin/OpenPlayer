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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        let song = AudioPlayer.sharedInstance.songsArray[indexPath.row]
        let AudioPlayerInst = AudioPlayer.sharedInstance
        //If there is a song that is playing inside a playlist, restore its view
        if AudioPlayerInst.player != nil
            && AudioPlayerInst.currentSong == song {
            cell.restorePlayingCell(song: AudioPlayerInst.currentSong!)
        } else {
            cell.initCell(initSong: song)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = AudioPlayer.sharedInstance.songsArray[indexPath.row]
            let SongPerstManager = SongPersistancyManager.sharedInstance
            var songsArray = AudioPlayer.sharedInstance.songsArray
            SongPerstManager.deleteEntity(toDelete: song,
                                          toDeleteUrl: SongPersistancyManager.sharedInstance.getSongPath(song: song),
                                          cntx: managedObjectContext!)
            songsArray = SongPerstManager.getSongArray(cntx: managedObjectContext, playlist: playlist)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    //  to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let songToMove = AudioPlayer.sharedInstance.songsArray[fromIndexPath.row]
        var songsArray = AudioPlayer.sharedInstance.songsArray
        songsArray.remove(at: fromIndexPath.row)
        songsArray.insert(songToMove, at: to.row)
        SongPersistancyManager.sharedInstance
            .resetSongsOrder(songArray: AudioPlayer.sharedInstance.songsArray,
                             cntx: managedObjectContext!)
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
