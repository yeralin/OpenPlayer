//
//  DownloadTableCellStates.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation

//AudioPlayerDelegate Callees
// MARK: Download cell states
extension DownloadCell {
    
    func prepareSongCellState() {
        if !playPauseButton.isRotating() {
            highlightedTimer = Timer.scheduledTimer(withTimeInterval: 0, repeats: true) { [weak self] _ in
                self?.playPauseButton.isHighlighted = true
            }
            playPauseButton.startRotating()
        }
        shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
        shuffleButton.isHidden = false
    }
    
    func playSongCellState() {
        if playPauseButton.isRotating() {
            playPauseButton.stopRotating()
            highlightedTimer?.invalidate()
            playPauseButton.isHighlighted = false
        }
        playPauseButton.isSelected = true
        restoreSliderCAD()
    }
    
    func pauseSongCellState() {
        if playPauseButton.isRotating() {
            playPauseButton.stopRotating()
            highlightedTimer?.invalidate()
            playPauseButton.isHighlighted = false
        }
        playPauseButton.isSelected = false
        // TODO: test this chunk
        if sliderCAD != nil {
            //sliderCAD.isPaused = true
        }
    }
    
    func resumeSongCellState() {
        if playPauseButton.isRotating() {
            playPauseButton.stopRotating()
            highlightedTimer?.invalidate()
            playPauseButton.isHighlighted = false
        }
        playPauseButton.isSelected = true
        if sliderCAD != nil {
            //sliderCAD.isPaused = false
        }
    }
    
    func stopSongCellState() {
        if playPauseButton.isRotating() {
            playPauseButton.stopRotating()
            highlightedTimer?.invalidate()
            playPauseButton.isHighlighted = false
        }
        playPauseButton.isSelected = false
        shuffleButton.isHidden = true
        resetSliderCAD()
    }
    
    func refreshSongCellState() {
        // refresh cell
    }
    
}
