//
//  PlaylistTableDataSource.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/15/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias PlaylistTableViewDataSource = PlaylistTableViewController
extension PlaylistTableViewDataSource {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        cell.playlistName.text = playlistArray[indexPath.row].playlistName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSongs", sender: playlistArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let songsView = segue.destination as! SongTableViewController
        if let playlist = sender as? PlaylistEntity {
            songsView.prepareSongs(receivedPlaylist: playlist)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            present(createDeletePlaylistAlert(onComplete: {_ in
                let playlist = self.playlistArray[indexPath.row]
                let playlistPerstManager = PlaylistPersistancyManager.sharedInstance
                playlistPerstManager.deleteEntity(toDelete: playlist,
                                                  toDeleteUrl: docsUrl.appendingPathComponent(playlist.playlistName!), cntx: self.managedObjectContext)
                self.playlistArray = playlistPerstManager.getPlaylistArray(cntx: self.managedObjectContext)
                self.playlistTableView.deleteRows(at: [indexPath], with: .fade)
                playlistPerstManager.resetPlaylistsOrder(playlistArray: self.playlistArray,
                                                                              cntx: self.managedObjectContext)
            }), animated: true, completion: nil)
            
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let playlistToMove = playlistArray[fromIndexPath.row]
        playlistArray.remove(at: fromIndexPath.row)
        playlistArray.insert(playlistToMove, at: to.row)
        PlaylistPersistancyManager.sharedInstance.resetPlaylistsOrder(playlistArray: playlistArray, cntx: managedObjectContext)
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        //Disable delete by swipe
        if playlistTableView.isEditing {
            return .delete
        }
        return .none
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
