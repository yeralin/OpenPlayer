//
//  SongTableSearchBar.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/13/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SongTableSearchBar = SongTableViewController
extension SongTableSearchBar: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if var searchText = searchBar.text, !searchText.isEmpty {
            searchText = searchText.lowercased()
            filteredSongs = songsArray?.filter { song in
                let normalizedSongName = (song.songName! as NSString)
                                            .deletingPathExtension
                                            .lowercased()
                return (normalizedSongName.contains(searchText))
            }
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
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
