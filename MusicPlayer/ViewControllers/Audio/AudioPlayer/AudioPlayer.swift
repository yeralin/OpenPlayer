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
            do {
                let songPath = try SongPersistencyManager.sharedInstance.getSongPath(song: song)
                let loadedPlayer = try AVAudioPlayer(contentsOf: songPath)
                self.player = loadedPlayer
                self.player.prepareToPlay()
                self.player.delegate = self
                currentSong = song
                delegate.cellState(state: .play, song: song)
                rc.updateMPControls(songArtist: song.songArtist!,
                                    songTitle: song.songTitle!,
                                    duration: player.duration)
                self.player.play()
            } catch let err {
                log.error("Could not play \"\(song.songName ?? "unknown")\" song: \(err)")
                return
            }
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
            do {
                let songsArray = try SongPersistencyManager.sharedInstance.getSongArray(playlist: song.playlist!)
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
            } catch let err {
                log.error("Could not play previous song: \(err)")
            }
        }
    }
    
    func playNextSong() {
        if let song = currentSong {
            do {
                if let playlist = song.playlist {
                    let songsArray = try SongPersistencyManager.sharedInstance.getSongArray(playlist: playlist)
                    guard let currSongIndex = songsArray.index(of: song) else {
                        throw "Could not get current song index for \"\(song.songName ?? "unknown")\""
                    }
                    var nextSongIndex = currSongIndex + 1
                    if shuffleMode == true {
                        nextSongIndex = Int(arc4random_uniform(UInt32(songsArray.count)))
                    }
                    if songsArray.indices.contains(nextSongIndex) {
                        self.playSong(song: songsArray[nextSongIndex])
                    } else {
                        self.stopSong()
                    }
                }
            } catch let err {
                log.error("Could not play next song: \(err)")
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
