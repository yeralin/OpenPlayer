//
//  SongTableCellStates.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/14/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons

//AudioPlayerDelegate Callees
private typealias SongTableCellStates = SongTableCell
extension SongTableCellStates {
    
    func initCell(initSong: SongEntity) {
        self.song = initSong
        if updateSlider != nil {
            updateSlider.invalidate()
        }
        updateSlider = nil
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
        editButton.setIcon(icon: .ionicons(.edit), iconSize: 24, color: .systemColor, forState: .normal)
        moveButton.setIcon(icon: .ionicons(.folder), iconSize: 28, color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = true
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }
    
    func restorePlayingCell(song: SongEntity) {
        self.song = song
        let audioPlayer = AudioPlayer.sharedInstance
        if audioPlayer.player.isPlaying {
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 23, color: .systemColor, forState: .normal)
        } else {
            playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
        }
        editButton.setIcon(icon: .ionicons(.edit), iconSize: 24, color: .systemColor, forState: .normal)
        moveButton.setIcon(icon: .ionicons(.folder), iconSize: 24, color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = false
        setupUpdateSlider()
    }
    
    func setShuffleButton() {
        if AudioPlayer.sharedInstance.shuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
        }
    }
    
    func playSongCellState() {
        //TODO: Replace/Test with one playPauseButton.setIcon(icon: .ionicons(.pause), iconSize: 26)
        if updateSlider == nil {
            setupUpdateSlider()
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26, color: .systemColor, forState: .normal)
            setShuffleButton()
            shuffleButton.isHidden = false
        } else {
            updateSlider.isPaused = false
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26, color: .systemColor, forState: .normal)
        }
        
    }
    
    func pauseSongCellState() {
        updateSlider.isPaused = true
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
    }
    
    func resetSongCellState() {
        updateSlider.invalidate()
        updateSlider = nil
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
        shuffleButton.isHidden = true
    }
    
    func setupUpdateSlider() {
        songProgressSlider.isEnabled = true
        songProgressSlider.minimumValue = 0
        songProgressSlider.maximumValue = Float(AudioPlayer.sharedInstance.player.duration)
        updateSlider = CADisplayLink(target: self, selector: #selector(self.updateAudioSlider))
        updateSlider.preferredFramesPerSecond = 60
        updateSlider.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    func updateAudioSlider() {
        if let player = AudioPlayer.sharedInstance.player, updateSlider != nil {
            songProgressSlider.value = Float(player.currentTime)
        }
    }
}
