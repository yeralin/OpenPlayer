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
        //TODO: Change logic, don't depend on title
        if playPauseButton.title(for: .normal) == FontType.ionicons(.play).text {
            AudioPlayer.sharedInstance.playSong(song: song)
        } else {
            AudioPlayer.sharedInstance.pauseSong()
        }
    }
    
    func actionOnShuffleTap() {
        //TODO: Change logic, don't depend on title
        if shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
            AudioPlayer.sharedInstance.shuffleMode = true
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
            AudioPlayer.sharedInstance.shuffleMode = false
        }
    }
    
    func actionOnMoveTap() {
        delegate.performSegueForCell(sender: song, identifier: "showPlaylistPicker")
    }
    
    func actionOnChangeSongNameTap() {
        delegate.presentAlertForCell(alert: changeSongNameAlert(), alertName: "presentChangeSongNameAlert")
    }
    
    func actionOnChangeSliderPosition(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        AudioPlayer.sharedInstance.seekTo(position: songNewPosition)
    }
}
