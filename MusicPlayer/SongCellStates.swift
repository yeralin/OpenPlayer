//
//  AudioPlayerDelegateImpl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
private typealias SongCellStates = SongCell
extension SongCellStates {
    
    //AudioPlayerDelegate Callees
    func setPlaySongCell() {
        setupUpdateSlider()
        playPauseButton.setIconWithSize(icon: pauseIcon, font: .Ionicon, size: 26)
        shuffleButton.isHidden = false
        if AudioPlayer.sharedInstance.shuffleMode == true {
            shuffleButton.setIconWithSize(icon: shuffleIcon, font: .Ionicon, size: 24)
        } else {
            shuffleButton.setIconWithSize(icon: nextIcon, font: .Ionicon, size: 24)
        }
    }
    
    func setPauseSongCell() {
        updateSlider.isPaused = true
        playPauseButton.setIconWithSize(icon: playIcon, font: .Ionicon, size: 24)
    }
    
    func setResumeSongCell() {
        updateSlider.isPaused = false
        playPauseButton.setIconWithSize(icon: pauseIcon, font: .Ionicon, size: 26)
    }
    
    func resetSongCell() {
        updateSlider.invalidate()
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
        playPauseButton.setIconWithSize(icon: playIcon, font: .Ionicon, size: 24)
        shuffleButton.isHidden = false
    }
}
