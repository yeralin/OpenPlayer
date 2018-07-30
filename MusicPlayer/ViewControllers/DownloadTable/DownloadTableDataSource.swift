//
//  DownloadTableDataSource.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/25/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import UIKit

private typealias DownloadTableViewDataSource = DownloadTableViewController
extension DownloadTableViewDataSource {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let streamAudioPlayerInst = StreamAudioPlayer.sharedInstance
        let song: DownloadSongEntity = searchSongs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadSongCell",
                                                 for: indexPath) as! DownloadTableCell
        cell.delegate = self
        //If there is a song that's playing inside current playlist, restore its state view
        if streamAudioPlayerInst.player != nil
            && streamAudioPlayerInst.currentSong! == song {
            cell.restorePlayingCell(song: song)
        } else {
            cell.initCell(initSong: song)
        }
        return cell
    }
}
