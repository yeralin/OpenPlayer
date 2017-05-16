//
//  AudioPlayerDelegateImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias AudioPlayerDelegateImpl = SongTableViewController
extension AudioPlayerDelegateImpl: AudioPlayerDelegate {
    
    func initAudioPlayerDelegateImpl() {
        AudioPlayer.sharedInstance.delegate = self
    }
    
    func cellPlayState(song: SongEntity) {
        let cell = getCell(atIndex: Int(song.songOrder))
        cell.setPlaySongCell()
    }
    
    func cellPauseState(song: SongEntity) {
        let cell = getCell(atIndex: Int(song.songOrder))
        cell.setPauseSongCell()
    }
    
    func cellResumeState(song: SongEntity) {
        let cell = getCell(atIndex: Int(song.songOrder))
        cell.setResumeSongCell()
    }
    
    func cellStopState(song: SongEntity) {
        let songArray = SongPersistancyManager.sharedInstance.getSongArray(cntx: managedObjectContext, playlist: self.playlist)
        if songArray.contains(song) {
            let cell = getCell(atIndex: Int(song.songOrder))
            cell.resetSongCell()
        }
    }
}
