//
//  DownloadTableSearchBar.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/25/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

private typealias DownloadTableSearchBar = DownloadTableViewController
extension DownloadTableSearchBar: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            try? AudioPlayer.instance.stop() // Ignore, player might be nil
            searchSongs.removeAll()
            tableView.reloadData()
        }
    }
    
    func parseSearchRequest(_ songListResponse: [[String:String]]) {
        guard let context = try? SongPersistencyManager.sharedInstance.validateContext(context: nil) else {
            fatalError("Could not fetch context")
        }
        for entry in songListResponse {
            if let songName = entry["title"], let url = entry["url"], let songUrl = URL(string: url) {
                let song = SongEntity(context: context)
                song.songTitle = songName
                song.songArtist = ""
                song.songName = songName
                song.songUrl = songUrl
                let tokSongName = songName.split(separator: "-", maxSplits: 1)
                if tokSongName.count == 2 {
                    song.songArtist = String(tokSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    song.songTitle = String(tokSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                searchSongs.append(song)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSongs.removeAll()
        try? AudioPlayer.instance.stop() // Ignore, player might be nil
        if var searchText = searchBar.text, !searchText.isEmpty {
            searchText = searchText.lowercased()
            self.showWaitOverlay()
            ServerRequests.sharedInstance.getSongs(query: searchText, endpoint: "/youtube/search",
                    completion: { songListResponse, requestError in
                        if let error = requestError {
                            var errorText = ""
                            switch error {
                            case RequestError.ConnectionIssue:
                                errorText = "Error: Could not connect to a server"
                            case RequestError.FailToParse:
                                errorText = "Error: Could not parse server response"
                            }
                            DispatchQueue.main.async {
                                self.removeAllOverlays()
                                let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            if let songListResponse = songListResponse {
                                DispatchQueue.main.async {
                                    self.removeAllOverlays()
                                    self.parseSearchRequest(songListResponse)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                })
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}
