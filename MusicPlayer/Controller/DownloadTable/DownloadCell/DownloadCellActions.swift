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
            AudioPlayer.instance.play(song: song)
        } else {
            AudioPlayer.instance.pause()
        }
    }
    
    internal func actionOnShuffleTap(isShuffleMode: Bool) {
        AudioPlayer.instance.shuffleMode = isShuffleMode
    }
    
    internal func actionOnDownloadTap() {
        delegate.performSegueForCell(sender: song, identifier: Constants.PRESENT_PLAYLIST_PICKER)
    }
    
    internal func actionOnChangeSliderPosition(position: TimeInterval) {
        AudioPlayer.instance.seekTo(position: position)
    }
}
