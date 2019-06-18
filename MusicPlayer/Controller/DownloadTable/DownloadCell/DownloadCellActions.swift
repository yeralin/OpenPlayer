//
//  DownloadCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/14/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation

private typealias DownloadCellActions = DownloadCell
extension DownloadCellActions {
    
    internal func actionOnPlayPauseTap(isPlaying: Bool, isInProgress: Bool) {
        if !isPlaying {
            StreamAudioPlayer.sharedInstance.playSong(song: song)
        } else {
            StreamAudioPlayer.sharedInstance.pauseSong()
        }
    }
    
    internal func actionOnShuffleTap(isShuffleMode: Bool) {
        StreamAudioPlayer.sharedInstance.shuffleMode = isShuffleMode
    }
    
    internal func actionOnDownloadTap() {
        delegate.performSegueForCell(sender: song, identifier: Constants.PRESENT_PLAYLIST_PICKER)
    }
    
    internal func actionOnChangeSliderPosition(position: TimeInterval) {
        StreamAudioPlayer.sharedInstance.seekTo(position: position)
    }
}
