//
//  SongCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons

private typealias SongCellUIActions = SongCell
extension SongCellUIActions {
    
    //TODO: Change logic, don't depend on title
    
    func actionOnPlayPauseTapUI() {
        let isStopped = playPauseButton.title(for: .normal) == FontType.ionicons(.play).text
        let isInProgress = songProgressSlider.value != 0 && songProgressSlider.isEnabled == true
        self.actionOnPlayPauseTap(isStopped: isStopped, isInProgress: isInProgress)
    }
    
    func actionOnShuffleTapUI() {
        let isShuffleMode = shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text
        if isShuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
        }
        actionOnShuffleTap(isShuffleMode: isShuffleMode)
    }
    
    func actionOnMoveTapUI() {
        delegate.performSegueForCell(sender: song, identifier: PRESENT_PLAYLIST_PICKER)
    }
    
    func actionOnChangeSongNameTapUI() {
        delegate.presentAlertForCell(alert: changeSongNameAlert(), alertName: PRESENT_CHANGE_SONG_NAME_ALERT)
    }
    
    func actionOnChangeSliderPositionUI(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        actionOnChangeSliderPosition(songNewPosition: songNewPosition)
    }
}
