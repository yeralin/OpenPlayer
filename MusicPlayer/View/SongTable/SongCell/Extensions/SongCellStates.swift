//
//  SongCellStates.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons

// AudioPlayerDelegate Callees
private typealias SongCellStates = SongCell
extension SongCellStates {
    
    func playSongCellState() {
        //TODO: Replace/Test with one playPauseButton.setIcon(icon: .ionicons(.pause), iconSize: 26)
        if sliderCAD == nil {
            setupSliderCAD()
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26, color: .systemColor, forState: .normal)
            setShuffleButton()
            shuffleButton.isHidden = false
        } else {
            sliderCAD.isPaused = false
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26, color: .systemColor, forState: .normal)
        }
    }
    
    func pauseSongCellState() {
        sliderCAD.isPaused = true
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
    }
    
    func stopSongCellState() {
        self.resetSliderCAD()
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
        shuffleButton.isHidden = true
    }
    
    
}
