//
//  SongCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/26/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias SongCellActions = SongCell
extension SongCellActions {
    
    func actionOnPlayPauseTap(isStopped: Bool, isInProgress: Bool) {
        let audioPlayerInst = AudioPlayer.sharedInstance
        //TODO: Change logic, don't depend on title
        if isStopped {
            if isInProgress {
                audioPlayerInst.resumeSong()
            } else {
                audioPlayerInst.playSong(song: song)
            }
        } else {
            audioPlayerInst.pauseSong()
        }
    }
    
    func actionOnShuffleTap(isShuffleMode: Bool) {
        let audioPlayerInst = AudioPlayer.sharedInstance
        audioPlayerInst.shuffleMode = isShuffleMode
    }
    
    func actionOnChangeSliderPosition(songNewPosition: TimeInterval) {
        AudioPlayer.sharedInstance.seekTo(position: songNewPosition)
    }
}
