//
//  SongTableSearchBar.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/13/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

// MARK: Song table search bar
extension SongTableViewController: UISearchBarDelegate {

    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            self.matchedSongs = filterSongsArrayBy(searchText: searchText)
            self.searching = true
        } else {
            self.searching = false
        }
        tableView.reloadData()
    }
    
    func filterSongsArrayBy(searchText: String) -> [SongEntity] {
        return songsArray.filter { song in
            if let songName = song.songName {
                let normalizedSongName = (songName as NSString)
                        .deletingPathExtension
                        .lowercased()
                return (normalizedSongName.contains(searchText.lowercased()))
            }
            return false
        }
    }

    /* Remove keyboard whevener following actions happen */

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

}
