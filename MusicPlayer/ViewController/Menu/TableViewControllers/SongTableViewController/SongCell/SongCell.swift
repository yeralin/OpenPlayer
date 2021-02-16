//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

class SongCell: BaseCell {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var songProgressSlider: UISlider!
    internal var sliderCAD: CADisplayLink!

    func initCell(initSong: SongEntity) {
        self.song = initSong
        if sliderCAD != nil {
            sliderCAD.invalidate()
        }
        sliderCAD = nil
        playPauseButton.isSelected = false
        shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
        shuffleButton.isHidden = true
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }

    func restorePlayingCell(song: SongEntity) {
        self.song = song
        playPauseButton.isSelected = AudioPlayer.instance.isPlaying()
        shuffleButton.isHidden = false
        shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
        restoreSliderCAD()
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        actionOnPlayPauseTap(isPlaying: sender.isSelected,
                             isInProgress: songProgressSlider.value != 0
                                && songProgressSlider.isEnabled == true)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        actionOnShuffleTap(isShuffleMode: !sender.isSelected)
        sender.isSelected = AudioPlayer.instance.shuffleMode
    }
    
    @IBAction func moveButtonTapped(_ sender: UIButton) {
        actionOnMoveTap()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        actionOnEditTap()
    }
    
    @IBAction func sliderPositionChanged(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        actionOnChangeSliderPosition(songNewPosition: songNewPosition)
    }
    
}
