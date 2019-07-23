//
//  AudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//
import MediaPlayer

enum PlayerState {
    case prepare
    case play
    case pause
    case resume
    case stop
}

protocol AudioPlayerDelegate : class {
    func getSongsArray(song: SongEntity) -> [SongEntity]
    func cellState(state: PlayerState, song: SongEntity)
    func propagateError(title: String, error: String)
}

extension AVPlayer {
    
    var isPlaying: Bool {
        get {
            return rate != 0 && error == nil
        }
    }
    
    var duration: Double {
        get {
            if let duration = self.currentItem?.duration.seconds {
                return duration
            } else {
                return Double.nan
            }
        }
    }
    
    var currentTime: Float {
        get {
            return Float(self.currentTime().seconds)
        }
    }
}

class LocalPlayerItem: AVPlayerItem {
    override open var duration: CMTime {
        get {
            return self.asset.duration
        }
    }
}

class AudioPlayer: NSObject, CachingPlayerItemDelegate {
    
    static let instance = AudioPlayer()
    // The delegate is intentionally not marked as weak
    var delegate: AudioPlayerDelegate?
    
    var shuffleMode: Bool = false
    var player: AVPlayer?
    var currentSong: SongEntity?
    var currentBufferValue: Double = 0
    private var rc: RemoteControl?
    
    override init() {
        super.init()
        rc?.resetMPControls()
        rc = RemoteControl.init(resumeSong: resume,
                                pauseSong: pause,
                                playNextSong: {() -> () in self.playNextSong(backward: false)},
                                playPreviousSong: {() -> () in self.playNextSong(backward: true)},
                                seekFor: seekFor(seconds:forward:))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption(notification:)),
                                               name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        rc?.resetMPControls()
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        scc.nextTrackCommand.removeTarget(self)
        scc.previousTrackCommand.removeTarget(self)
        scc.seekBackwardCommand.removeTarget(self)
        scc.seekForwardCommand.removeTarget(self)
    }
    
    func isPlaying(song: SongEntity) -> Bool {
        if let _ = self.player, let currentSong = self.currentSong {
            return song == currentSong
        }
        return false
    }
    
    func play(song: SongEntity) {
        if self.isPlaying(song: song) {
            resume()
            return
        }
        self.stop()
        self.currentSong = song
        // Determine whether playing a remote or local audio file
        if let remoteSongUrl = song.songUrl, let songName = song.songName {
            let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let localSongUrl = tempUrl.appendingPathComponent(songName).appendingPathExtension("mp3")
            if FileManager.default.fileExists(atPath: localSongUrl.relativePath) {
                // Song was already cached, not yet saved
                self.playLocal(localSongUrl)
                delegate?.cellState(state: .play, song: song)
            } else {
                self.playRemote(remoteSongUrl)
                delegate?.cellState(state: .prepare, song: song)
            }
        } else {
            do {
                let localSongUrl = try SongPersistencyManager.sharedInstance.getSongPath(song: song)
                self.playLocal(localSongUrl)
                delegate?.cellState(state: .play, song: song)
            } catch let error {
                fatalError("Could not play local audio file: \(error)")
            }
        }
        
        guard let songArtist = song.songArtist,
            let songTitle = song.songTitle else {
                log.error("Could not unwrap SongEntity: \(song)")
                return
        }
        rc?.setMPControls(songArtist: songArtist, songTitle: songTitle, duration: player?.duration ?? .nan)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playNextSong(backward:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    private func playRemote(_ remoteSongUrl: URL) {
        let playerItem = CachingPlayerItem(url: remoteSongUrl, customFileExtension: "mp3")
        playerItem.delegate = self
        let player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        player.play()
        self.player = player
    }
    
    private func playLocal(_ localSongUrl: URL) {
        let localPlayerItem = LocalPlayerItem(url: localSongUrl)
        let player = AVPlayer(playerItem: localPlayerItem)
        player.play()
        self.player = player
        self.currentBufferValue = 1
    }
    
    func resume() {
        if let currentSong = self.currentSong {
            if let player = self.player {
                player.play()
                delegate?.cellState(state: .resume,song: currentSong)
                rc?.updateMP(state: .resume, currentTime: player.currentTime().seconds)
            } else {
                play(song: currentSong)
            }
        }
        
    }
    
    func stop() {
        if let player = self.player, let currentSong = currentSong {
            //player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
            player.pause()
            let startCmTime = CMTime(seconds: 0, preferredTimescale: 1)
            player.currentItem?.seek(to: startCmTime, completionHandler: nil)
            self.player = nil
            delegate?.cellState(state: .stop, song: currentSong)
            rc?.resetMPControls()
        }
    }
    
    func pause() {
        if let player = self.player, let currentSong = currentSong, player.isPlaying {
            delegate?.cellState(state: .pause, song: currentSong)
            player.pause()
            rc?.updateMP(state: .pause)
        }
    }
    
    func seekFor(seconds: Double, forward: Bool) {
        if let player = self.player, let currentTime = player.currentItem?.currentTime() {
            let forCmTime = CMTime(seconds: seconds, preferredTimescale: 1000000)
            let seekTo = forward ? currentTime + forCmTime : currentTime - forCmTime
            player.currentItem?.seek(to: seekTo, completionHandler: nil)
            rc?.updateMP(state: .resume, currentTime: player.currentTime().seconds)
        }
    }
    
    func seekTo(position: TimeInterval) {
        if let player = self.player {
            let toCmTime = CMTime(seconds: position, preferredTimescale: 1000000)
            player.currentItem?.seek(to: toCmTime, completionHandler: nil)
            rc?.updateMP(state: .resume, currentTime: player.currentTime().seconds)
        }
    }
    
    @objc internal func playNextSong(backward: Bool = false) {
        if let currentSong = currentSong,
           let songsArray = delegate?.getSongsArray(song: currentSong) {
            var nextSongIndex: Int = -1
            if shuffleMode == true {
                nextSongIndex = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else if let currSongIndex = songsArray.firstIndex(of: currentSong) {
                nextSongIndex = backward ? currSongIndex - 1 : currSongIndex + 1
            }
            if songsArray.indices.contains(nextSongIndex) {
                play(song: songsArray[nextSongIndex])
            } else {
                stop()
            }
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
            self.pause()
        case .ended:
            guard let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                log.error("Could not extract interruption options")
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
            if options.contains(.shouldResume) {
                self.resume()
            }
        @unknown default:
            log.error("Unhandled interruption type has occured")
        }
    }
    
    // Delegate methods
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        log.info("Ready to play...")
        if let player = self.player {
            let duration = playerItem.asset.duration.seconds
            rc?.updateMPDuration(duration: duration)
            delegate?.cellState(state: .play, song: currentSong!)
            player.play()
        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        log.info("Finished downloading")
        DispatchQueue.main.sync {
            if let songName = currentSong?.songName {
                let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                let destUrl = tempUrl.appendingPathComponent(songName).appendingPathExtension("mp3")
                do {
                    log.info("Writing to a file: \(destUrl)")
                    try data.write(to: destUrl, options: .atomic)
                } catch {
                    log.error("Failed writing file to \(destUrl) " +
                        "Error: " + error.localizedDescription)
                }
            }
        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didReceiveResponse response: HTTPURLResponse) {
        log.debug("Received response: \(response)")
        DispatchQueue.main.sync {
            if let rawSeconds = response.allHeaderFields["Audio-Duration"] as? String,
                let seconds = Double(rawSeconds), seconds > 0 {
                playerItem.duration = CMTimeMakeWithSeconds(seconds, preferredTimescale: 600)
            }
        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        log.info("Loaded so far: \(bytesDownloaded) out of \(bytesExpected)")
        DispatchQueue.main.sync {
            self.currentBufferValue = Double(bytesDownloaded/(bytesExpected/100))/100
        }
    }
    
    func playerItemDidStopPlayback(playerItem: CachingPlayerItem) {
        log.info("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        DispatchQueue.main.sync {
            if let currentSong = currentSong {
                delegate?.cellState(state: .prepare, song: currentSong)
            }
        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        log.error("The streaming has failed due to: \(error.localizedDescription)")
        DispatchQueue.main.sync {
            if let currentSong = currentSong, error._code != NSURLErrorCancelled {
                delegate?.propagateError(title: "The streaming has failed", error: error.localizedDescription)
                delegate?.cellState(state: .stop, song: currentSong)
            }
        }
    }
    
}
