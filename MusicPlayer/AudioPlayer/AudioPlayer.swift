//
//  AudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/24/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import MediaPlayer

enum State {
    case play
    case pause
    case resume
    case stop
}

protocol AudioPlayerDelegate : class {
    func cellState(state: State, song: SongEntity)
}


class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    var player : AVAudioPlayer! {
        didSet {
            player.enableRate = true
        }
    }
    var songsArray = [SongEntity]()
    var currentSong: SongEntity?
    var shuffleMode = false
    weak var delegate: AudioPlayerDelegate!
    
    static let sharedInstance = AudioPlayer()
    
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
    
    deinit {
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        scc.nextTrackCommand.removeTarget(self)
        scc.previousTrackCommand.removeTarget(self)
        scc.seekBackwardCommand.removeTarget(self)
        scc.seekForwardCommand.removeTarget(self)
    }
    
    func playSong(song: SongEntity) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        if player != nil && !player.isPlaying && song == currentSong {
            resumeSong()
        } else {
            stopSong()
            self.player?.delegate = nil
            let songPath = SongPersistancyManager.sharedInstance.getSongPath(song: song)
            guard let p = try? AVAudioPlayer(contentsOf: songPath) else {
                print("Could not resolve song path \(songPath.absoluteString)")
                return
            }
            self.player = p
            self.player.prepareToPlay()
            self.player.delegate = self
            currentSong = song
            delegate.cellState(state: State.play, song: song)
            self.player.play()
            updateControlls()
        }
    }
    
    func resumeSong() {
        if let song = currentSong {
            if player == nil {
                playSong(song: song)
            }
            if !player.isPlaying {
                player.play()
                delegate?.cellState(state: State.play,song: song)
                updateControllsTime(state: State.resume)
            }
        }
        
    }
    
    func stopSong() {
        if player != nil {
            if let song = currentSong {
                player?.stop()
                player.currentTime = 0
                player = nil
                delegate?.cellState(state: State.stop,song: song)
                updateControllsTime(state: State.stop)
            }
        }
    }
    
    func pauseSong() {
        if player != nil && player.isPlaying {
            if let song = currentSong {
                delegate?.cellState(state: State.pause, song: song)
                player.pause()
                updateControllsTime(state: State.pause)
            }
        }
    }
    
    var seekFor: TimeInterval!
    func handleSeekForwardCommandEvent(event: MPSeekCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch event.type {
        case .beginSeeking:
            seekFor = NSDate.timeIntervalSinceReferenceDate
        case .endSeeking:
            seekFor = (NSDate.timeIntervalSinceReferenceDate - seekFor)*5
            player.currentTime += seekFor
        }
        return .success
    }
    
    func handleSeekBackwardCommandEvent(event: MPSeekCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch event.type {
        case .beginSeeking:
            seekFor = NSDate.timeIntervalSinceReferenceDate
        case .endSeeking:
            seekFor = (NSDate.timeIntervalSinceReferenceDate - seekFor)*5
            player.currentTime -= seekFor
        }
        return .success
    }
    
    func seekTo(position: TimeInterval) {
        if player != nil {
            player.currentTime = position
            updateControllsTime(state: State.resume)
        }
    }
    
    func playPreviousSong() {
        var prevSong = 0
        if let song = currentSong {
            if shuffleMode == true {
                prevSong = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                prevSong = songsArray.index(of: song)! - 1
            }
            if songsArray.indices.contains(prevSong) {
                self.playSong(song: songsArray[prevSong])
            } else {
                stopSong()
            }
        }
    }
    
    func playNextSong() {
        var nextSong = 0
        if let song = currentSong {
            if shuffleMode == true {
                nextSong = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                nextSong = songsArray.index(of: song)! + 1
            }
            if songsArray.indices.contains(nextSong) {
                self.playSong(song: songsArray[nextSong])
            } else {
                stopSong()
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }
    
    func getCurrentTimeAsString() -> String {
        var seconds = 0
        var minutes = 0
        if let time = player?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    
    
}
