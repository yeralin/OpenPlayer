//
//  PlaylistTableDataSource.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/15/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}

private typealias PlaylistTableViewDataSource = PlaylistTableViewController
extension PlaylistTableViewController {
    
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
        performSegue(withIdentifier: "presentSongs", sender: playlistArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentSongs" {
            let songsView = segue.destination as! SongTableViewController
            if let playlist = sender as? PlaylistEntity {
                songsView.prepareSongs(receivedPlaylist: playlist)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            present(createDeletePlaylistAlert(onComplete: { _ in
                let playlist = self.playlistArray[indexPath.row]
                do {
                    let playlistPerstManager = PlaylistPersistencyManager.sharedInstance
                    try playlistPerstManager.deletePlaylist(playlist: playlist)
                    self.playlistArray = try playlistPerstManager.getPlaylistArray()
                    self.playlistTableView.deleteRows(at: [indexPath], with: .fade)
                    self.playlistArray = try playlistPerstManager.resetPlaylistsOrder(playlistArray: self.playlistArray)
                } catch let err {
                    log.error("Could not delete playlist \"\(playlist.playlistName ?? "unknown")\": \(err)")
                }
            }), animated: true, completion: nil)
            
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let playlistToMove = playlistArray[fromIndexPath.row]
        do {
            let playlistPerstManager = PlaylistPersistencyManager.sharedInstance
            playlistArray.remove(at: fromIndexPath.row)
            playlistArray.insert(playlistToMove, at: to.row)
            self.playlistArray = try playlistPerstManager.resetPlaylistsOrder(playlistArray: playlistArray)
        } catch let err {
            log.error("Could not rearrange \"\(playlistToMove.playlistName ?? "unknown") playlist: \(err)")
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
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
