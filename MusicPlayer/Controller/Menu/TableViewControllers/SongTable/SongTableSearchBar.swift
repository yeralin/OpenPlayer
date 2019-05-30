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

    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if var searchText = searchBar.text, !searchText.isEmpty {
            searchText = searchText.lowercased()
            self.matchedSongs = songsArray.filter { song in
                if let songName = song.songName {
                    let normalizedSongName = (songName as NSString)
                            .deletingPathExtension
                            .lowercased()
                    return (normalizedSongName.contains(searchText))
                }
                return false
            }
            self.searching = true
        } else {
            self.searching = false
        }
        tableView.reloadData()
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
