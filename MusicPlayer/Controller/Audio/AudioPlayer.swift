//
//  LocalAudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import MediaPlayer


class AudioPlayer: BaseAudioPlayer, AVAudioPlayerDelegate {

    var player: AVAudioPlayer?
    
    static let sharedInstance = AudioPlayer()
    
    override init() {
        super.init()
        super.initRemoteControl(resumeSong: resumeSong,
                   pauseSong: pauseSong,
                   playNextSong: {() -> () in self.playNextSong(forward: true)},
                   playPreviousSong: {() -> () in self.playNextSong(forward: false)},
                   seekFor: seekFor(seconds:forward:))
    }
    
    func playSong(song: SongEntity) {
        guard let song = song as? LocalSongEntity else {
            fatalError("Failed to resume the player: could not get currentSong")
        }
        if let player = self.player {
            if !player.isPlaying, song == currentSong {
                resumeSong()
                return
            }
            stopSong()
        }
        do {
            self.player?.delegate = nil
            let songPath = try SongPersistencyManager.sharedInstance.getSongPath(song: song)
            let loadedPlayer = try AVAudioPlayer(contentsOf: songPath)
            if !loadedPlayer.prepareToPlay() {
                log.warning("Could not preload player's buffers")
            }
            loadedPlayer.delegate = self
            currentSong = song
            loadedPlayer.play()
            self.player = loadedPlayer
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleInterruption(notification:)),
                                                   name: AVAudioSession.interruptionNotification, object: nil)
            delegate?.cellState(state: .play, song: song)
            rc?.setMPControls(songArtist: song.songArtist!,
                                 songTitle: song.songTitle!,
                                 duration: loadedPlayer.duration)
        } catch let err {
            fatalError("Could not play \"\(song.songName ?? "unknown")\" song: \(err)")
        }
    }

    func resumeSong() {
        guard let song = currentSong as? LocalSongEntity else {
            fatalError("Failed to resume the player: could not get currentSong")
        }
        if let player = self.player {
            player.play()
            delegate?.cellState(state: .resume, song: song)
            rc?.updateMP(state: .resume, currentTime: player.currentTime)
        } else {
            playSong(song: song)
        }
    }
    
    func stopSong() {
        guard let player = self.player else {
            log.info("Player is not initialized, nothing to do")
            return
        }
        guard let song = currentSong as? LocalSongEntity else {
            fatalError("Failed to resume the player: could not get currentSong")
        }
        player.stop()
        player.currentTime = 0
        delegate?.cellState(state: .stop,song: song)
        rc?.updateMP(state: .stop)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        self.player = nil
    }
    
    func pauseSong() {
        guard let player = self.player else {
            log.info("Player is not initialized, nothing to do")
            return
        }
        if !player.isPlaying {
            log.warning("Player is not playing, nothing to do")
            return
        }
        guard let song = currentSong as? LocalSongEntity else {
            fatalError("Failed to pause the player: could not get currentSong")
        }
        player.pause()
        delegate?.cellState(state: .pause, song: song)
        rc?.updateMP(state: .pause, currentTime: player.currentTime)
    }
    
    func seekFor(seconds: Double, forward: Bool) {
        guard let player = self.player else {
            log.info("Player is not initialized, nothing to do")
            return
        }
        let currentTime = player.currentTime
        let seekFor = forward ? currentTime + seconds : currentTime - seconds
        if seekFor < 0 || seekFor >= player.duration {
            stopSong()
        } else {
            player.currentTime = forward ? player.currentTime + seconds : player.currentTime - seconds
        }
        rc?.updateMP(state: .resume, currentTime: player.currentTime)
    }
    
    func seekTo(position: TimeInterval) {
        guard let player = self.player else {
            log.info("Player is not initialized, nothing to do")
            return
        }
        player.currentTime = position
        rc?.updateMP(state: .resume, currentTime: player.currentTime)
    }
    
    func playNextSong(forward: Bool) {
        var nextSongIndex: Int
        guard let song = currentSong as? LocalSongEntity else {
            fatalError("Failed to pause the player: could not get currentSong")
        }
        do {
            guard let playlist = song.playlist else {
                throw "Could not extract a playlist for \"\(song.songName ?? "unknown")\""
            }
            let songsArray = try SongPersistencyManager.sharedInstance.getSongArray(playlist: playlist)
            guard let currSongIndex = songsArray.firstIndex(of: song) else {
                throw "Could not get current song index for \"\(song.songName ?? "unknown")\""
            }
            if shuffleMode == true {
                nextSongIndex = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                nextSongIndex = forward ? currSongIndex + 1: currSongIndex - 1
            }
            if songsArray.indices.contains(nextSongIndex) {
                self.playSong(song: songsArray[nextSongIndex])
            } else {
                stopSong()
            }
        } catch let err {
            fatalError("Could not play a next song: \(err)")
        }
    }
    
    internal func getCurrentTimeAsString() -> String {
        var seconds = 0
        var minutes = 0
        if let time = player?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    @objc internal func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeInt) else {
                return
        }
        switch type {
        case .began:
            self.pauseSong()
        case .ended:
            guard let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                log.error("Could not extract interruption options")
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
            if options.contains(.shouldResume) {
                self.resumeSong()
            }
        @unknown default:
            log.error("Unhandled interruption type has occured")
        }
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong(forward: true) // by default plays songs in a forward order
    }
}
