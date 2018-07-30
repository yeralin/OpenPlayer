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
    
    var _resumeSong: () -> ()
    var _pauseSong: () -> ()
    var _playNextSong: () -> ()
    var _playPreviousSong: () -> ()
    
    func resumeSong() { _resumeSong() }
    func pauseSong() { _pauseSong() }
    func playNextSong() { _playNextSong() }
    func playPreviousSing() { _playPreviousSong() }
    
    init(resumeSongClosure: @escaping () -> (),
         pauseSongClosure: @escaping () -> (),
         playNextSongClosure: @escaping () -> (),
         playPreviousSongClosure: @escaping () -> ()) {
        _resumeSong = resumeSongClosure
        _pauseSong = pauseSongClosure
        _playNextSong = playNextSongClosure
        _playPreviousSong = playPreviousSongClosure
        super.init()
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.addTarget(self, action: #selector(resumeSong))
        scc.pauseCommand.addTarget(self, action: #selector(pauseSong))
        scc.nextTrackCommand.addTarget(self, action: #selector(playNextSong))
        scc.previousTrackCommand.addTarget(self, action: #selector(playPreviousSing))
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
