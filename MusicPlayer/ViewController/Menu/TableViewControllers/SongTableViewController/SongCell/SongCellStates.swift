//
//  SongCellStates.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

// AudioPlayerDelegate Callees
// MARK: Song cell states
extension SongCell {
    
    func playSongCellState() {
        playPauseButton.isSelected = true
        if sliderCAD == nil {
            restoreSliderCAD()
            shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
            shuffleButton.isHidden = false
        } else {
            sliderCAD.isPaused = false
        }
    }
    
    func pauseSongCellState() {
        sliderCAD.isPaused = true
        playPauseButton.isSelected = false
    }
    
    func stopSongCellState() {
        self.resetSliderCAD()
        playPauseButton.isSelected = false
        shuffleButton.isHidden = true
    }
    
    
}
