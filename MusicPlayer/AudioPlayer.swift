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
    func cellResumeState(song: SongEntity)
    func cellStopState(song: SongEntity)
}

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    var player : AVAudioPlayer!
    var songsArray = [SongEntity]()
    var currentSong: SongEntity?
    var shuffleMode = false
    weak var delegate: AudioPlayerDelegate!
    
    static let sharedInstance = AudioPlayer()
    
    func playSong(song: SongEntity) {
        if player != nil && !player.isPlaying && song == currentSong {
            resumeSong()
        } else {
            stopSong()
            self.player?.delegate = nil
            let songPath = SongPersistancyManager.sharedInstance.getSongPath(song: song)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Could not attach AVAudioSession")
            }
            guard let p = try? AVAudioPlayer(contentsOf: songPath) else {
                print("Could not resolve song path \(songPath.absoluteString)")
                return
            }
            self.player = p
            self.player.prepareToPlay()
            self.player.delegate = self
            currentSong = song
            delegate.cellPlayState(song: currentSong!)
            self.player.play()
        }
    }
    /*
    UIApplication.shared.beginReceivingRemoteControlEvents()
    let scc = MPRemoteCommandCenter.shared()
    scc.playCommand.addTarget(self, action:#selector(performPlay))
    scc.pauseCommand.addTarget(self, action:#selector(performPause))
    scc.togglePlayPauseCommand.addTarget(self, action: #selector(performPlayPause))
    
    func performPlayPause(_ event:MPRemoteCommandEvent) {
        let player = AudioPlayer.sharedInstance.player
        if player!.isPlaying { player?.pause() } else { player?.play() }
    }
    func performPlay(_ event:MPRemoteCommandEvent) {
        let player = AudioPlayer.sharedInstance.player
        player!.play()
    }
    func performPause(_ event:MPRemoteCommandEvent) {
        let player = AudioPlayer.sharedInstance.player
        player!.pause()
    }
    */
    func resumeSong() {
        if player != nil && !player.isPlaying {
            player.play()
            delegate?.cellResumeState(song: currentSong!)
        }
    }
    
    func stopSong() {
        if player != nil {
            player?.stop()
            delegate?.cellStopState(song: currentSong!)
            currentSong = nil
        }
    }
    
    func pauseSong() {
        if player != nil && player.isPlaying {
            delegate?.cellPauseState(song: currentSong!)
            player.pause()
        }
    }
    
    func seekTo(position: TimeInterval) {
        if player != nil {
            player.currentTime = position
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        var nextSong = 0
        if shuffleMode == true {
            nextSong = Int(arc4random_uniform(UInt32(songsArray.count)))
        } else {
            nextSong = songsArray.index(of: currentSong!)! + 1
        }
        if songsArray.indices.contains(nextSong) {
            self.playSong(song: songsArray[nextSong])
        } else {
            stopSong()
        }
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
