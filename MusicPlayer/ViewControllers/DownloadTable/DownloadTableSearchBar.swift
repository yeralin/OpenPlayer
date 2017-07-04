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
            searchSongs.removeAll()
        }
        tableView.reloadData()
    }
    
    func parseSearchRequestResponse(_ songListResponse: [[String:String]]) {
        let songUrlBase = ServerRequests.sharedInstance.serverAddress!
            .appendingPathComponent("youtube/stream")
        for entry in songListResponse {
            var song: DownloadSongEntity = DownloadSongEntity()
            if let videoId = entry["videoId"] {
                let queryItem = [URLQueryItem(name: "videoId", value: videoId)]
                let urlBuild = NSURLComponents(string: songUrlBase.absoluteString)
                urlBuild?.queryItems = queryItem
                song.songUrl = urlBuild?.url
            }
            if let songName = entry["title"] {
                song.songName = songName
                song.songTitle = songName
                song.songArtist = ""
                let tokSongName = songName.characters.split(separator: "-")
                if tokSongName.count == 2 {
                    song.songArtist = String(tokSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    song.songTitle = String(tokSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
            }
            searchSongs.append(song)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if var searchText = searchBar.text, !searchText.isEmpty {
            searchText = searchText.lowercased()
            self.showWaitOverlay()
            ServerRequests.sharedInstance.getSongs(query: searchText, endpoint: "youtube/search",
                    completion: { songListResponse, requestError in
                        self.removeAllOverlays()
                        if let error = requestError {
                            var errorText = ""
                            switch error {
                            case RequestError.ConnectionIssue:
                                errorText = "Error: Could not connect to a server"
                            case RequestError.FailToParse:
                                errorText = "Error: Could not parse server response"
                            }
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            self.parseSearchRequestResponse(songListResponse!)
                            self.tableView.reloadData()
                        }
                        
                })
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}
