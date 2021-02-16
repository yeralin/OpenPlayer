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

struct SearchResultEntry: Codable {
    var source: String
    var title: String
    var url: URL
}

// MARK: Download table search bar
extension DownloadTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            try? AudioPlayer.instance.stop() // Ignore, player might be nil
            searchSongs.removeAll()
            tableView.reloadData()
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSongs.removeAll()
        try? AudioPlayer.instance.stop() // Ignore, player might be nil
        if var searchText = searchBar.text, !searchText.isEmpty {
            searchText = searchText.lowercased()
            self.showWaitOverlay()
            ServerRequests.sharedInstance.getSongs(query: searchText,
                                                   completion: parseSearchResponse(responseData:responseStatus:))
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    private func parseSearchResponse(responseData: Data?, responseStatus: Response) {
        do {
            if responseStatus != .Successful {
                throw "Unsuccessful HTTP request"
            }
            if  let responseData = responseData {
                let decoder = JSONDecoder()
                let songListResponse = try decoder.decode([SearchResultEntry].self, from: responseData)
                DispatchQueue.main.async {
                    self.removeAllOverlays()
                    self.populateSongListResponse(songListResponse)
                    self.tableView.reloadData()
                }
            } else {
                var responseStatus = Response.FailedToParse
                throw "Failed to parse the response"
            }
        } catch {
            var errorMessage: String?
            switch responseStatus {
            case .ConnectionIssue:
                errorMessage = "Error: Could not connect to the server"
            case .FailedToParse:
                errorMessage = "Error: Could not parse server response"
            case .ServerUndefined:
                errorMessage = "Error: No server URL was defined in settings"
            default:
                errorMessage = "Error: Unknown error occurred"
            }
            DispatchQueue.main.async {
                self.removeAllOverlays()
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func populateSongListResponse(_ songListResponse: [SearchResultEntry]) {
        guard let context = try? SongPersistencyManager.sharedInstance.validateContext(context: nil) else {
            fatalError("Could not fetch context")
        }
        for entry in songListResponse {
            let song = SongEntity(context: context)
            song.songName = entry.title
            song.songUrl = entry.url
            let tokSongName = entry.title.split(separator: "-", maxSplits: 1)
            if tokSongName.count == 2 {
                song.songArtist = String(tokSongName[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                song.songTitle = String(tokSongName[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                song.songTitle = entry.title
                song.songArtist = ""
            }
            searchSongs.append(song)
        }
    }
}
