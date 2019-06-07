//
//  RemoteControl.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

@objcMembers
class RemoteControl: NSObject {

    init(resumeSong: @escaping () -> (),
         pauseSong: @escaping () -> (),
         playNextSong: @escaping () -> (),
         playPreviousSong: @escaping () -> ()) {
        super.init()
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.addTarget(handler: { _ in
            resumeSong()
            return .success
        })
        scc.pauseCommand.addTarget(handler: { _ in
            pauseSong()
            return .success
        })
        scc.nextTrackCommand.addTarget(handler: { _ in
            playNextSong()
            return .success
        })
        scc.previousTrackCommand.addTarget(handler: { _ in
            playPreviousSong()
            return .success
        })
        scc.seekBackwardCommand.addTarget(self, action: #selector(handleSeekBackwardCommandEvent(event:)))
        scc.seekForwardCommand.addTarget(self, action: #selector(handleSeekForwardCommandEvent(event:)))
    }
    
    func resetMPControls() {
        let mpic = MPNowPlayingInfoCenter.default()
        let scc = MPRemoteCommandCenter.shared()
        mpic.nowPlayingInfo = nil
        scc.pauseCommand.removeTarget(self)
        scc.nextTrackCommand.removeTarget(self)
        scc.previousTrackCommand.removeTarget(self)
        scc.seekBackwardCommand.removeTarget(self)
        scc.seekForwardCommand.removeTarget(self)

    }
    
    func updateMPControls(songArtist: String, songTitle: String, duration: Double = .nan) {
        let mpic = MPNowPlayingInfoCenter.default()
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyArtist: songArtist,
            MPMediaItemPropertyTitle: songTitle,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
    }
    
    func updateMP(state: PlayerState, currentTime: Double = .nan) {
        let mpic = MPNowPlayingInfoCenter.default()
        if var meta = mpic.nowPlayingInfo {
            if state == .pause {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 0
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            } else if state == .resume {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 1
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            } else if state == .stop {
                meta[MPMediaItemPropertyArtist] = nil
                meta[MPMediaItemPropertyTitle] = nil
                meta[MPMediaItemPropertyPlaybackDuration] = 0
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 0
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            }
            mpic.nowPlayingInfo = meta
        }
    }
    
    func updateMPDuration(duration: Double) {
        let mpic = MPNowPlayingInfoCenter.default()
        mpic.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
    }

    // TODO: Implement seeking capability for RemoteControl
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
