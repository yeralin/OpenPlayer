//
//  DownloadTableCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons
import MediaPlayer

// MARK: Download cell UI actions
extension DownloadCell {
    
    internal func actionOnPlayPauseTapUI() {
        //TODO: Change logic, don't depend on title
        let isPlaying = playPauseButton.title(for: .normal) != FontType.ionicons(.play).text
        let isInProgress = songProgressSlider.value != 0 && songProgressSlider.isEnabled == true
        self.actionOnPlayPauseTap(isPlaying: isPlaying, isInProgress: isInProgress)
    }
    
    internal func actionOnShuffleTapUI() {
        //TODO: Change logic, don't depend on title
        let isShuffleMode = shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text
        if isShuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
        }
        actionOnShuffleTap(isShuffleMode: isShuffleMode)
    }
    
    internal func actionOnDownloadTapUI() {
        self.actionOnDownloadTap()
    }
    
    internal func actionOnChangeSliderPositionUI(_ sender: UISlider) {
        if let songNewPosition = TimeInterval(exactly: sender.value) {
            self.actionOnChangeSliderPosition(position: songNewPosition)
        }
    }
}
