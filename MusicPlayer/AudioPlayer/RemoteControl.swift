//
//  RemoteControl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

private typealias RemoteControl = AudioPlayer
extension RemoteControl {
    
    
    
    func updateControlls() {
        let mpic = MPNowPlayingInfoCenter.default()
        if let song = currentSong {
            mpic.nowPlayingInfo = [
                MPMediaItemPropertyArtist: song.songArtist!,
                MPMediaItemPropertyTitle: song.songTitle!,
                MPMediaItemPropertyPlaybackDuration: self.player.duration,
                MPNowPlayingInfoPropertyPlaybackRate: 1
            ]
        }
    }
    
    func updateControllsTime(state: State) {
        let mpic = MPNowPlayingInfoCenter.default()
        if var meta = mpic.nowPlayingInfo {
            if state == State.pause {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 0
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            } else if state == State.resume {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 1
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            } else if state == State.stop {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 0
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            }
            mpic.nowPlayingInfo = meta
        }
    }
    
    func initAudioPlayer() {
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.addTarget(self, action: #selector(resumeSong))
        scc.pauseCommand.addTarget(self, action: #selector(pauseSong))
        scc.nextTrackCommand.addTarget(self, action: #selector(playNextSong))
        scc.previousTrackCommand.addTarget(self, action: #selector(playPreviousSong))
        scc.seekBackwardCommand.addTarget(self, action: #selector(handleSeekBackwardCommandEvent(event:)))
        scc.seekForwardCommand.addTarget(self, action: #selector(handleSeekForwardCommandEvent(event:)))
    }
    
    func handleSeekForwardCommandEvent(event: MPSeekCommandEvent) -> MPRemoteCommandHandlerStatus {
        /*switch event.type {
        case .beginSeeking:
            seekFor = NSDate.timeIntervalSinceReferenceDate
        case .endSeeking:
            seekFor = (NSDate.timeIntervalSinceReferenceDate - seekFor)*5
            player.currentTime += seekFor
        }*/
        return .success
    }
    
    func handleSeekBackwardCommandEvent(event: MPSeekCommandEvent) -> MPRemoteCommandHandlerStatus {
        /*switch event.type {
        case .beginSeeking:
            seekFor = NSDate.timeIntervalSinceReferenceDate
        case .endSeeking:
            seekFor = (NSDate.timeIntervalSinceReferenceDate - seekFor)*5
            player.currentTime -= seekFor
        }*/
        return .success
    }
}
