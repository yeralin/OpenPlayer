//
//  SongTablePlaylistPickerImpl
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias SongTablePlaylistPickerImpl = SongTableViewController
extension SongTablePlaylistPickerImpl: PlaylistPickerDelegate {

    internal func moveSong(song: SongEntity, toPlaylist: PlaylistEntity) {
        if let fromPlaylist = self.playlist {
            do {
                let songPerstManager = SongPersistencyManager.sharedInstance
                try songPerstManager.moveSong(toMoveSong: song, fromPlaylist: fromPlaylist, toPlaylist: toPlaylist)
                var songsArray = try songPerstManager.getSongsArray(playlist: self.playlist)
                songsArray = try songPerstManager.resetSongOrder(songArray: songsArray)
                try songPerstManager.saveContext()
                self.songsArray = songsArray
                songTableView.deleteRows(at: [IndexPath(row: Int(song.songOrder), section: 0)], with: .fade)
            } catch let err {
                log.error("""
                          Could not move \"\(song.songName ?? "unknown")\" song 
                          to \"\(toPlaylist)\" playlist: \(err)
                          """)
            }
        }
    }
    
    
}
