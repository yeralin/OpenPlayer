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
class MPControl: NSObject {
    
    var seekWorker: DispatchWorkItem? = nil
    var seekFor: (_ seconds: Double, _ forward: Bool) -> ()

    init(resumeSong: @escaping () -> (),
         pauseSong: @escaping () -> (),
         playNextSong: @escaping () -> (),
         playPreviousSong: @escaping () -> (),
         seekFor: @escaping (_ seconds: Double, _ forward: Bool) -> ()) {
        self.seekFor = seekFor
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
        scc.seekBackwardCommand.addTarget(handler: { event in
            guard let event = event as? MPSeekCommandEvent else {
                log.error("Could not cast MPRemoteCommandEvent to MPSeekCommandEvent")
                return .commandFailed
            }
            return self.handleRemoteControlSeek(event: event, forward: false)
        })
        scc.seekForwardCommand.addTarget(handler: { event in
            guard let event = event as? MPSeekCommandEvent else {
                log.error("Could not cast MPRemoteCommandEvent to MPSeekCommandEvent")
                return .commandFailed
            }
            return self.handleRemoteControlSeek(event: event, forward: true)
        })
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
    
func setMPControls(songArtist: String, songTitle: String, duration: Double = .nan) {
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
    
    internal func initSeekWorker(_ forward: Bool) -> DispatchWorkItem? {
        return DispatchWorkItem { [weak self] in
            var timesSeeked = 0
            var seekTime: Double = 5 // sec
            while true {
                if self?.seekWorker?.isCancelled ?? true {
                    // Worker received cancellation signal
                    self?.seekWorker = nil
                    break
                }
                // Seek in a main thread bc it affects UI
                DispatchQueue.main.sync {
                    self?.seekFor(seekTime, forward)
                }
                // Sleep for 1 second after each seek
                sleep(1)
                // Double seekTime after two times seeked
                if timesSeeked % 2 == 0 {
                    seekTime *= 2
                }
                timesSeeked += 1
            }
        }
    }
    
    internal func handleRemoteControlSeek(event: MPSeekCommandEvent, forward: Bool) -> MPRemoteCommandHandlerStatus {
        switch event.type {
        case .beginSeeking:
            if let seekWorker = initSeekWorker(forward) {
                DispatchQueue.global(qos: .userInteractive).async(execute: seekWorker)
                self.seekWorker = seekWorker
            }
        case .endSeeking:
            seekWorker?.cancel()
        @unknown default:
            log.error("Unhandled case detected")
        }
        return .success
    }
    
}
