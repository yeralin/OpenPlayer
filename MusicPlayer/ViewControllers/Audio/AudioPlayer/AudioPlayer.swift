//
//  LocalAudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import MediaPlayer


class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    var player: AVAudioPlayer!
    var currentSong: SongEntity?
    var shuffleMode: Bool = false
    var rc: RemoteControl!
    weak var delegate: AudioPlayerDelegate!
    
    static let sharedInstance = AudioPlayer()
    
    override init() {
        super.init()
        rc = RemoteControl.init(resumeSongClosure: resumeSong,
                                pauseSongClosure: pauseSong,
                                playNextSongClosure: playNextSong,
                                playPreviousSongClosure: playPreviousSong)
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }
    
    func playSong(song: SongEntity) {
        if player != nil && !player.isPlaying && song == currentSong {
            resumeSong()
        } else {
            self.stopSong()
            StreamAudioPlayer.sharedInstance.stopSong()
            self.player?.delegate = nil
            let songPath = SongPersistancyManager.sharedInstance.getSongPath(song: song)
            guard let p = try? AVAudioPlayer(contentsOf: songPath) else {
                log.error("Could not resolve song path \(songPath.absoluteString)")
                return
            }
            self.player = p
            self.player.prepareToPlay()
            self.player.delegate = self
            currentSong = song
            
            delegate.cellState(state: .play, song: song)
            rc.updateMPControls(songArtist: song.songArtist!,
                                songTitle: song.songTitle!,
                                duration: player.duration)
            self.player.play()
        }
    }
    
    func resumeSong() {
        if let song = currentSong {
            if player == nil {
                playSong(song: song)
            }
            player.play()
            delegate?.cellState(state: .resume,song: song)
            rc.updateMP(state: .resume, currentTime: player.currentTime)
        }
        
    }
    
    func stopSong() {
        if player != nil {
            if let song = currentSong {
                player!.stop()
                player.currentTime = 0
                player = nil
                delegate?.cellState(state: .stop,song: song)
                rc.updateMP(state: .stop)
            }
        }
    }
    
    func pauseSong() {
        if player != nil && player.isPlaying {
            if let song = currentSong {
                delegate?.cellState(state: .pause, song: song)
                player.pause()
                rc.updateMP(state: .pause, currentTime: player.currentTime)
            }
        }
    }
    
    
    
    func seekTo(position: TimeInterval) {
        if player != nil {
            player.currentTime = position
            rc.updateMP(state: .resume, currentTime: player.currentTime)
        }
    }
    
    func playPreviousSong() {
        var prevSongIndex = 0
        if let song = currentSong {
            let songsArray = SongPersistancyManager.sharedInstance.getSongArray(playlist: song.playlist!)
            if shuffleMode == true {
                prevSongIndex = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                prevSongIndex = songsArray.index(of: song)! - 1
            }
            if songsArray.indices.contains(prevSongIndex) {
                self.playSong(song: songsArray[prevSongIndex])
            } else {
                stopSong()
            }
        }
    }
    
    func playNextSong() {
        if let song = currentSong {
            let songsArray = SongPersistancyManager.sharedInstance.getSongArray(playlist: song.playlist!)
            var nextSongIndex = 0
            if shuffleMode == true {
                nextSongIndex = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                nextSongIndex = songsArray.index(of: song)! + 1
            }
            if songsArray.indices.contains(nextSongIndex) {
                self.playSong(song: songsArray[nextSongIndex])
            } else {
                stopSong()
            }
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
