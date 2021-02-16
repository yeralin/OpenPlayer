//
//  DownloadTablePlaylistPickerImpl
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

// MARK: Download table playlist picker delegate implementation
extension DownloadTableViewController: PlaylistPickerDelegate {

    func moveSong(songCell: BaseCell, toPlaylist: PlaylistEntity) {
        /*if let fromPlaylist = self.playlist {
            let songPerstManager = SongPersistencyManager.sharedInstance
            let rowPosition = Int(song.songOrder)
            songPerstManager.moveSong(toMove: song, fromPlaylist: fromPlaylist, toPlaylist: toPlaylist)
            let songsArray = songPerstManager.getSongArray(playlist: self.playlist)
            song.songOrder = -1
            self.songsArray = songsArray.enumerated().map { (index, song) in
                song.songOrder = Int32(index)
                return song
            }
            songPerstManager.saveContext()
            songTableView.deleteRows(at: [IndexPath(row: rowPosition, section: 0)], with: .fade)
        }*/
    }
    
    
}

