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
    
    func songMovedPlaylist(song: SongEntity, toPlaylist: PlaylistEntity) {
        let songPerstManager = SongPersistancyManager.sharedInstance
        let audioPlayer = AudioPlayer.sharedInstance
        let rowPosition = Int(song.songOrder)
        songPerstManager.moveSongToPlaylist(toMove: song, toPlaylist: toPlaylist)
        audioPlayer.songsArray = songPerstManager.getSongArray(cntx: managedObjectContext, playlist: self.playlist)
        SongPersistancyManager.sharedInstance
            .resetSongsOrder(songArray: AudioPlayer.sharedInstance.songsArray,
                             cntx: managedObjectContext!)
        songTableView.deleteRows(at: [IndexPath(row: rowPosition, section: 0)], with: .fade)
    }


}
