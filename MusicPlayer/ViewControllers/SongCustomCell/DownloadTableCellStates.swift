//
//  DownloadTableCellStates.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons

//AudioPlayerDelegate Callees
private typealias DownloadTableCellStates = DownloadTableCell
extension DownloadTableCellStates {
    
    func prepareSongCellState() {
        playPauseButton.setIcon(icon: .ionicons(.loadC), iconSize: 26,
                                color: .systemColor,  forState: .normal)
        playPauseButton.startRotating()
        setShuffleButton()
        shuffleButton.isHidden = false
    }
    
    func playSongCellState() {
        playPauseButton.stopRotating()
        playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26,
                                color: .systemColor, forState: .normal)
        if sliderCAD == nil {
            setupSliderCAD()
        }
        
    }
    
    func pauseSongCellState() {
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                color: .systemColor, forState: .normal)
        if sliderCAD != nil {
            sliderCAD.isPaused = true
        }
    }
    
    func resumeSongCellState() {
        playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26,
                                color: .systemColor, forState: .normal)
        if sliderCAD != nil {
            sliderCAD.isPaused = false
        }
    }
    
    func stopSongCellState() {
        resetSliderCAD()
        playPauseButton.stopRotating()
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                color: .systemColor, forState: .normal)
        shuffleButton.isHidden = true
    }
    
    func refreshSongCellState() {
        
        if let player = StreamAudioPlayer.sharedInstance.player,
           let duration = player.currentItem?.asset.duration.seconds,
            !duration.isNaN {
            DispatchQueue.main.async() {
                self.songProgressSlider.maximumValue = Float(duration)
            }
        }
    }
    
}
