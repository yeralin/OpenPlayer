//
//  SongTableCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIcons

private typealias SongTableCellActions = SongTableCell
extension SongTableCellActions {
    
    func actionOnPlayPauseTap() {
        let audioPlayerInst = AudioPlayer.sharedInstance
        //TODO: Change logic, don't depend on title
        if playPauseButton.title(for: .normal) == FontType.ionicons(.play).text {
            if songProgressSlider.value != 0 && songProgressSlider.isEnabled == true {
                audioPlayerInst.resumeSong()
            } else {
                audioPlayerInst.playSong(song: song)
            }
        } else {
            audioPlayerInst.pauseSong()
        }
    }
    
    func actionOnShuffleTap() {
        let audioPlayerInst = AudioPlayer.sharedInstance
        //TODO: Change logic, don't depend on title
        if shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
            audioPlayerInst.shuffleMode = true
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
            audioPlayerInst.shuffleMode = false
        }
    }
    
    func actionOnMoveTap() {
        delegate.performSegueForCell(sender: song, identifier: PRESENT_PLAYLIST_PICKER)
    }
    
    func actionOnChangeSongNameTap() {
        delegate.presentAlertForCell(alert: changeSongNameAlert(), alertName: PRESENT_CHANGE_SONG_NAME_ALERT)
    }
    
    func actionOnChangeSliderPosition(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        AudioPlayer.sharedInstance.seekTo(position: songNewPosition)
    }
}
