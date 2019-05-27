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
            StreamAudioPlayer.sharedInstance.stopSong()
            searchSongs.removeAll()
            tableView.reloadData()
        }
    }
    
    func parseSearchRequest(_ songListResponse: [[String:String]]) {
        let songUrlBase = ServerRequests.sharedInstance.serverAddress!
            .appendingPathComponent("youtube/stream").absoluteString
        for entry in songListResponse {
            if let songName = entry["title"], let videoId = entry["videoId"] {
                let urlBuild = NSURLComponents(string: songUrlBase)!
                urlBuild.queryItems = [URLQueryItem(name: "videoId", value: videoId)]
                let songUrl = urlBuild.url!
                var song = DownloadSongEntity(songTitle: songName, songArtist: "", songName: songName, songUrl: songUrl)
                
                let tokSongName = songName.split(separator: "-")
                if tokSongName.count == 2 {
                    song.songArtist = String(tokSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    song.songTitle = String(tokSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                searchSongs.append(song)
            }
        }
        StreamAudioPlayer.sharedInstance.songsArray = searchSongs
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSongs.removeAll()
        StreamAudioPlayer.sharedInstance.stopSong()
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
                            DispatchQueue.main.async {
                                self.removeAllOverlays()
                                self.parseSearchRequest(songListResponse!)
                                self.tableView.reloadData()
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
