//
//  MoveToPickerViewDelegateImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias MoveToPickerViewDelegateImpl = SongTableViewController
extension MoveToPickerViewDelegateImpl: MoveToPickerViewDelegate {
    
    func moveSong(song: SongEntity, toPlaylist: PlaylistEntity) {
        if let fromPlaylist = self.playlist {
            let songPerstManager = SongPersistancyManager.sharedInstance
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
        }
    }
    
    
}
