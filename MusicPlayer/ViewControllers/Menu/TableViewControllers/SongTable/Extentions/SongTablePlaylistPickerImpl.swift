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
    
    func moveSong(song: SongEntity, toPlaylist: PlaylistEntity) {
        if let fromPlaylist = self.playlist {
            do {
                let songPerstManager = SongPersistencyManager.sharedInstance
                let rowPosition = Int(song.songOrder)
                try songPerstManager.moveSong(toMoveSong: song, fromPlaylist: fromPlaylist, toPlaylist: toPlaylist)
                var songsArray = try songPerstManager.getSongArray(playlist: self.playlist)
                song.songOrder = -1
                songsArray = try songPerstManager.resetSongOrder(songArray: songsArray)
                try songPerstManager.saveContext()
                songTableView.deleteRows(at: [IndexPath(row: rowPosition, section: 0)], with: .fade)
            } catch let err {
                log.error(err)
            }
        }
    }
    
    
}
