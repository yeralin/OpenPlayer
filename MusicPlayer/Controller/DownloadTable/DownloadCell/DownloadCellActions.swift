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
        do {
            if !isPlaying {
                try AudioPlayer.instance.play(song: song)
            } else {
                try AudioPlayer.instance.pause()
            }
        } catch let error {
            delegate.propagateError(title: "Audio player failed", error: error.localizedDescription)
        }
    }
    
    internal func actionOnShuffleTap(isShuffleMode: Bool) {
        AudioPlayer.instance.shuffleMode = isShuffleMode
    }
    
    internal func actionOnDownloadTap() {
        delegate.performSegueForCell(sender: song, identifier: Constants.PRESENT_PLAYLIST_PICKER)
    }
    
    internal func actionOnChangeSliderPosition(position: TimeInterval) {
        do {
            try AudioPlayer.instance.seekTo(position: position)
        } catch let error {
            delegate.propagateError(title: "Audio player failed", error: error.localizedDescription)
        }
    }
}
