//
//  SongCellActions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/26/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation

// MARK: Song cell actions
extension SongCell {

    internal func actionOnPlayPauseTap(isPlaying: Bool, isInProgress: Bool) {
        let audioPlayerInst = AudioPlayer.instance
        //TODO: Change logic, don't depend on title
        do {
            if !isPlaying {
                if isInProgress {
                    try audioPlayerInst.resume()
                } else {
                    try audioPlayerInst.play(song: song)
                }
            } else {
                try audioPlayerInst.pause()
            }
        } catch let error {
            delegate.propagateError(title: "Audio player failed", error: error.localizedDescription)
        }
    }

    internal func actionOnShuffleTap(isShuffleMode: Bool) {
            AudioPlayer.instance.shuffleMode = isShuffleMode
    }

    internal func actionOnChangeSliderPosition(songNewPosition: TimeInterval) {
        do {
            try AudioPlayer.instance.seekTo(position: songNewPosition)
        } catch let error {
            delegate.propagateError(title: "Audio player failed", error: error.localizedDescription)
        }
    }
}
