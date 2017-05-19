//
//  AudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/24/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import MediaPlayer

protocol AudioPlayerDelegate : class {
    func cellPlayState(song: SongEntity)
    func cellPauseState(song: SongEntity)
    func cellStopState(song: SongEntity)
}


class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    var player : AVAudioPlayer!
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
    
    enum State {
        case paused
        case resumed
        case stopped
    }
    
    func updateControllsTime(state: State) {
        let mpic = MPNowPlayingInfoCenter.default()
        if var meta = mpic.nowPlayingInfo {
            if state == State.paused {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 0
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            } else if state == State.resumed {
                meta[MPNowPlayingInfoPropertyPlaybackRate] = 1
                meta[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            } else if state == State.stopped {
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
        scc.seekBackwardCommand.addTarget(self, action: #selector(seekBackward))
        scc.seekForwardCommand.addTarget(self, action: #selector(seekForward))
    }
    
    deinit {
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
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
            delegate.cellPlayState(song: song)
            self.player.play()
            updateControlls()
        }
    }
    
    func resumeSong() {
        if let song = currentSong {
            if !player.isPlaying {
                player.play()
                delegate?.cellPlayState(song: song)
                updateControllsTime(state: State.resumed)
            }
        }
        
    }
    
    func stopSong() {
        if player != nil {
            if let song = currentSong {
                player?.stop()
                player.currentTime = 0
                delegate?.cellStopState(song: song)
                updateControllsTime(state: State.stopped)
            }
        }
    }
    
    func pauseSong() {
        if player != nil && player.isPlaying {
            if let song = currentSong {
                delegate?.cellPauseState(song: song)
                player.pause()
                updateControllsTime(state: State.paused)
            }
        }
    }
    
    func seekBackward() {
        if player != nil {
            player.currentTime -= TimeInterval(10)
            if player.isPlaying {
                updateControllsTime(state: State.resumed)
            } else {
                updateControllsTime(state: State.paused)
            }
        }
    }
    
    func seekForward() {
        if player != nil {
            player.currentTime += TimeInterval(10)
            if player.isPlaying {
                updateControllsTime(state: State.resumed)
            } else {
                updateControllsTime(state: State.paused)
            }
            
        }
    }
    
    func seekTo(position: TimeInterval) {
        if player != nil {
            player.currentTime = position
            updateControllsTime(state: State.resumed)
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
