//
//  SongCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons

// MARK: Song cell UI actions
extension SongCell {
    
    //TODO: Change logic, don't depend on title

    internal func actionOnPlayPauseTapUI() {
        let isPlaying = playPauseButton.title(for: .normal) != FontType.ionicons(.play).text
        let isInProgress = songProgressSlider.value != 0 && songProgressSlider.isEnabled == true
        self.actionOnPlayPauseTap(isPlaying: isPlaying, isInProgress: isInProgress)
    }

    internal func actionOnShuffleTapUI() {
        let isShuffleMode = shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text
        if isShuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
        }
        actionOnShuffleTap(isShuffleMode: isShuffleMode)
    }

    internal func actionOnMoveTapUI() {
        delegate.performSegueForCell(sender: song, identifier: Constants.PRESENT_PLAYLIST_PICKER)
    }

    internal func actionOnChangeSongNameTapUI() {
        delegate.presentAlertForCell(alert: changeSongNameAlert(), alertName: Constants.PRESENT_CHANGE_SONG_NAME_ALERT)
    }

    internal func actionOnChangeSliderPositionUI(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        actionOnChangeSliderPosition(songNewPosition: songNewPosition)
    }
}
