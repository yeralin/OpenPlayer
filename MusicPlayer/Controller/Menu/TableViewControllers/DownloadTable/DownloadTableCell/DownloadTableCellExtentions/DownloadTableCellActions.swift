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

private typealias DownloadTableCellActions = DownloadTableCell
extension DownloadTableCellActions {
    
    func actionOnPlayPauseTap() {
        //TODO: Change logic, don't depend on title
        if playPauseButton.title(for: .normal) == FontType.ionicons(.play).text {
            StreamAudioPlayer.sharedInstance.playSong(song: song)
        } else {
            StreamAudioPlayer.sharedInstance.pauseSong()
        }
    }
    
    func actionOnShuffleTap() {
        //TODO: Change logic, don't depend on title
        if shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
            StreamAudioPlayer.sharedInstance.shuffleMode = true
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
            StreamAudioPlayer.sharedInstance.shuffleMode = false
        }
    }
    
    func actionOnDownloadTap() {
        delegate.performSegueForCell(sender: song, identifier: PRESENT_PLAYLIST_PICKER)
    }
    
    func actionOnChangeSliderPosition(_ sender: UISlider) {
        let songNewPosition: CMTime = CMTimeMakeWithSeconds(Float64(sender.value), preferredTimescale: 1)
        StreamAudioPlayer.sharedInstance.seekTo(position: songNewPosition)
    }
}
