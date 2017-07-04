//
//  DownloadTableCellStates.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons
import CoreMedia

//AudioPlayerDelegate Callees
private typealias DownloadTableCellStates = DownloadTableCell
extension DownloadTableCellStates {
    
    func initCell(initSong: DownloadSongEntity) {
        self.song = initSong
        if updateSlider != nil {
            updateSlider.invalidate()
        }
        updateSlider = nil
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                color: .systemColor, forState: .normal)
        downloadButton.setIcon(icon: .ionicons(.iosCloudDownload), iconSize: 28,
                               color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = true
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }
    
    func restorePlayingCell(song: DownloadSongEntity) {
        self.song = song
        let audioPlayer = StreamAudioPlayer.sharedInstance
        if audioPlayer.player.isPlaying {
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 23,
                                    color: .systemColor, forState: .normal)
        } else {
            playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                    color: .systemColor, forState: .normal)
        }
        downloadButton.setIcon(icon: .ionicons(.iosDownload), iconSize: 24,
                               color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = false
        setupUpdateSlider()
    }
    
    func prepareSongCellState() {
        playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26,
                                color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = false
    }
    
    func playSongCellState() {
        if updateSlider == nil {
            setupUpdateSlider()
        }
        
    }
    
    func resumeSongCellState() {
        playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 26,
                                color: .systemColor, forState: .normal)
        if updateSlider != nil {
            updateSlider.isPaused = false
        }
    }
    
    func pauseSongCellState() {
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                color: .systemColor, forState: .normal)
        if updateSlider != nil {
            updateSlider.isPaused = true
        }
    }
    
    func resetSongCellState() {
        resetUpdateSlider()
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
    
    func setShuffleButton() {
        if StreamAudioPlayer.sharedInstance.shuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26,
                                  color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26,
                                  color: .systemColor, forState: .normal)
        }
    }
    
    func resetUpdateSlider() {
        if updateSlider != nil {
            updateSlider.invalidate()
            updateSlider = nil
            songProgressSlider.value = 0
            songProgressSlider.isEnabled = false
        }
    }
    
    //Todo: setupSlider on observer
    //custom state when duration is not provided (disable slider)
    
    func setupUpdateSlider() {
        if let player = StreamAudioPlayer.sharedInstance.player {
            songProgressSlider.isEnabled = true
            songProgressSlider.minimumValue = 0
            if player.duration.seconds.isNaN {
                songProgressSlider.maximumValue = Float(300)
            } else {
                songProgressSlider.maximumValue = Float(player.duration.seconds)
            }
            updateSlider = CADisplayLink(target: self, selector: #selector(self.updateAudioSlider))
            updateSlider.preferredFramesPerSecond = 60
            updateSlider.add(to: .current, forMode: .defaultRunLoopMode)
        }
    }
    
    func updateAudioSlider() {
        if let player = StreamAudioPlayer.sharedInstance.player, updateSlider != nil {
            songProgressSlider.value = Float(player.currentTime().seconds)
        }
    }
}
