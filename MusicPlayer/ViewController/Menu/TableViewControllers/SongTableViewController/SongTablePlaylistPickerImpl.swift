//
//  SongTablePlaylistPickerImpl
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

// MARK: Song table picker implementation
extension SongTableViewController: PlaylistPickerDelegate {

    internal func moveSong(songCell: BaseCell, toPlaylist: PlaylistEntity) {
        if let fromPlaylist = self.playlist {
            do {
                let songPerstManager = SongPersistencyManager.sharedInstance
                try songPerstManager.moveSong(toMoveSong: songCell.song, fromPlaylist: fromPlaylist, toPlaylist: toPlaylist)
                var songsArray = try songPerstManager.getSongsArray(playlist: self.playlist)
                songsArray = try songPerstManager.resetSongOrder(songArray: songsArray)
                try songPerstManager.saveContext()
                self.songsArray = songsArray
                if searching, let searchText = searchBar.text {
                    self.matchedSongs = filterSongsArrayBy(searchText: searchText)
                }
                songTableView.deleteRows(at: [IndexPath(row: songCell.rowIndex, section: 0)], with: .fade)
            } catch SongPersistenceCntrlError.FileAlreadyExists {
                present(popUIErrorAlert(title: "Could not move the song",
                                        reason: "The song already exists in the target playlist"),
                        animated: true)
            } catch let err {
                log.error("""
                          Could not move \"\(songCell.song.songName ?? "unknown")\" song
                          to \"\(toPlaylist.playlistName ?? "unknown")\" playlist: \(err)
                          """)
            }
        }
    }
    
    
}
