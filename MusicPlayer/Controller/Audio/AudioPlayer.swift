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

open class PlayerItem: AVPlayerItem {
    
    public var bufferValue: Double = 1
    private(set) var assignedSong: SongEntity
    
    override open var duration: CMTime {
        get {
            return self.asset.duration
        }
    }
    
    // Default: For playing local items
    init(song: SongEntity) {
        self.assignedSong = song
        super.init(asset: AVAsset(url: song.getSongUrl()), automaticallyLoadedAssetKeys: ["duration"])
    }
    
    // More customizable: for playing remote items
    init(song: SongEntity, asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        self.assignedSong = song
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}

class AudioPlayer: NSObject {
    
    static let instance = AudioPlayer()
    private let audioDownloadManager = AudioDownloadManager()
    // The delegate is intentionally not marked as weak
    var delegate: AudioPlayerDelegate?
    
    var shuffleMode: Bool = false
    var player: AVPlayer?
    var currentPlayerItem: PlayerItem?
    var currentSong: SongEntity? {
        get {
            return currentPlayerItem?.assignedSong
        }
    }
    private var mp: MPControl?
    
    override init() {
        super.init()
        mp?.resetMPControls()
        mp = MPControl.init(resumeSong: resume,
                                pauseSong: pause,
                                playNextSong: {() -> () in self.playNextSong(backward: false)},
                                playPreviousSong: {() -> () in self.playNextSong(backward: true)},
                                seekFor: seekFor(seconds:forward:))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption(notification:)),
                                               name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remotePlayerItemReceivedHttpResponse(_:)),
                                               name: .receivedHttpResponse, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remotePlayerItemReadyToPlay(_:)),
                                               name: .readyToPlay, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remotePlayerItemErrored(_:)),
                                               name: .errored, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remotePlayerItemStalled(_:)),
                                               name: .stalled, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remotePlayerItemDownloadProgress(_:)),
                                               name: .downloadProgress, object: nil)
    }
    
    deinit {
        mp?.resetMPControls()
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        scc.nextTrackCommand.removeTarget(self)
        scc.previousTrackCommand.removeTarget(self)
        scc.seekBackwardCommand.removeTarget(self)
        scc.seekForwardCommand.removeTarget(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    func isPlaying(song: SongEntity) -> Bool {
        if let _ = self.player, let currentSong = self.currentSong {
            return song == currentSong
        }
        return false
    }
    
    func play(song: SongEntity) throws {
        if self.isPlaying(song: song) {
            try resume()
            return
        }
        try? stop() // Ignore, player might be nil
        // Determine whether playing a remote or local audio file
        if song.isRemote() && song.isCached() == nil {
            self.currentPlayerItem = self.playRemote(song)
            delegate?.cellState(state: .prepare, song: song)
        } else {
            self.currentPlayerItem = self.playLocal(song)
            delegate?.cellState(state: .play, song: song)
        }
        
        guard let songArtist = song.songArtist,
            let songTitle = song.songTitle else {
                throw "Could not unwrap SongEntity: \(song)"
        }
        mp?.setMPControls(songArtist: songArtist, songTitle: songTitle, duration: player?.duration ?? .nan)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playNextSong(backward:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    private func playRemote(_ song: SongEntity) -> RemotePlayerItem {
        let remotePlayerItem = RemotePlayerItem(song: song)
        let player = AVPlayer(playerItem: remotePlayerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        self.player = player
        return remotePlayerItem
    }
    
    private func playLocal(_ song: SongEntity) -> PlayerItem {
        let localPlayerItem = PlayerItem(song: song)
        let player = AVPlayer(playerItem: localPlayerItem)
        player.play()
        self.player = player
        return localPlayerItem
    }
    
    func resume() throws {
        guard let currentSong = self.currentSong else {
            throw "Could not locate currentSong, nothing to resume"
        }
        if let player = self.player {
            player.play()
            delegate?.cellState(state: .resume,song: currentSong)
            mp?.updateMP(state: .resume, currentTime: player.currentTime().seconds)
        } else {
            try play(song: currentSong)
        }
    }
    
    func stop() throws {
        guard let player = self.player, let currentSong = currentSong else {
            throw "Could not locate an active player, nothing to stop"
        }
        player.pause()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        self.player = nil
        delegate?.cellState(state: .stop, song: currentSong)
        mp?.resetMPControls()
    }
    
    func pause() throws {
        guard let player = self.player, let currentSong = currentSong, player.isPlaying else {
            throw "Could not locate an active player, nothing to pause"
        }
        delegate?.cellState(state: .pause, song: currentSong)
        player.pause()
        mp?.updateMP(state: .pause, currentTime: player.currentTime().seconds)
    }
    
    func seekFor(seconds: Double, forward: Bool) throws {
        guard let player = self.player, let currentTime = player.currentItem?.currentTime() else {
            throw "Could not locate an active player, nothing to seek"
        }
        let forCmTime = CMTime(seconds: seconds, preferredTimescale: 1000000)
        let seekTo = forward ? currentTime + forCmTime : currentTime - forCmTime
        player.currentItem?.seek(to: seekTo, completionHandler: nil)
        mp?.updateMP(state: .resume, currentTime: seekTo.seconds)
    }
    
    func seekTo(position: TimeInterval) throws {
        guard let player = self.player else {
            throw "Could not locate an active player, nothing to seek"
        }
        let toCmTime = CMTime(seconds: position, preferredTimescale: 1000000)
        player.currentItem?.seek(to: toCmTime, completionHandler: nil)
        mp?.updateMP(state: .resume, currentTime: player.currentTime().seconds)
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
    
    @objc internal func playNextSong(backward: Bool = false) {
        do {
            guard let currentSong = currentSong,
               let songsArray = delegate?.getSongsArray(song: currentSong) else {
                throw "Could not locate songsArray"
            }
            var nextSongIndex: Int = -1
            if shuffleMode == true {
                nextSongIndex = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else if let currSongIndex = songsArray.firstIndex(of: currentSong) {
                nextSongIndex = backward ? currSongIndex - 1 : currSongIndex + 1
            }
            if songsArray.indices.contains(nextSongIndex) {
                try play(song: songsArray[nextSongIndex])
            } else {
                try stop()
            }
        } catch let error {
            fatalError("Reached internal inconsistency: \(error)")
        }
    }
    
    @objc internal func handleInterruption(notification: Notification) {
        do {
            guard let userInfo = notification.userInfo,
                let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeInt) else {
                    return
            }
            switch type {
            case .began:
                try pause()
            case .ended:
                guard let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    log.error("Could not extract interruption options")
                    return
                }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
                if options.contains(.shouldResume) {
                    try resume()
                }
            @unknown default:
                log.error("Unhandled interruption type has occured")
            }
        } catch let error {
            fatalError("Reached internal inconsistency: \(error)")
        }
    }
    
    // Handle notifications methods
    
    @objc internal func remotePlayerItemReadyToPlay(_ notification: Notification) {
        guard let remotePlayerItem = notification.object as? RemotePlayerItem,
              let player = self.player,
              let currentSong = self.currentSong,
                  remotePlayerItem.assignedSong == currentSong else {
            log.error("Could not properly handle a notification: \(notification)")
            return
        }
        let duration = remotePlayerItem.asset.duration.seconds
        mp?.updateMPDuration(duration: duration)
        delegate?.cellState(state: .play, song: currentSong)
        player.playImmediately(atRate: 1)
    }
    
    @objc internal func remotePlayerItemErrored(_ notification: Notification) {
        guard let remotePlayerItem = notification.object as? RemotePlayerItem,
            let error = remotePlayerItem.error,
            let currentSong = self.currentSong,
                remotePlayerItem.assignedSong == currentSong else {
                log.error("Could not properly handle a notification: \(notification)")
                return
        }
        log.error("The streaming has failed due to: \(error.localizedDescription)")
        DispatchQueue.main.sync {
            if error._code != NSURLErrorCancelled {
                delegate?.propagateError(title: "The streaming has failed", error: error.localizedDescription)
                delegate?.cellState(state: .stop, song: currentSong)
            }
        }
    }
    
    @objc internal func remotePlayerItemStalled(_ notification: Notification) {
        guard let remotePlayerItem = notification.object as? RemotePlayerItem,
            let currentSong = self.currentSong,
                remotePlayerItem.assignedSong == currentSong else {
                log.error("Could not properly handle a notification: \(notification)")
                return
        }
        log.info("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        DispatchQueue.main.sync {
            delegate?.cellState(state: .prepare, song: currentSong)
        }
    }
    
    @objc internal func remotePlayerItemDownloadProgress(_ notification: Notification) {
        guard let remotePlayerItem = notification.object as? RemotePlayerItem,
            let bytesDownloaded = remotePlayerItem.bytesDownloaded,
            let totalBytesExpected = remotePlayerItem.bytesTotal,
            let currentSong = self.currentSong,
            remotePlayerItem.assignedSong == currentSong else {
                log.error("Could not properly handle a notification: \(notification)")
                return
        }
        log.debug("Loaded so far: \(bytesDownloaded) out of \(totalBytesExpected)")
        DispatchQueue.main.sync {
            remotePlayerItem.bufferValue = Double(bytesDownloaded/(totalBytesExpected/100))/100
        }
    }
    
    @objc internal func remotePlayerItemReceivedHttpResponse(_ notification: Notification) {
        guard let remotePlayerItem = notification.object as? RemotePlayerItem,
            let httpResponse = remotePlayerItem.httpResponse,
            let currentSong = self.currentSong,
            remotePlayerItem.assignedSong == currentSong else {
                log.error("Could not properly handle a notification: \(notification)")
                return
        }
        log.info("Received response: \(httpResponse)")
        DispatchQueue.main.sync {
            if let rawSeconds = httpResponse.allHeaderFields["Audio-Duration"] as? String,
                let seconds = Double(rawSeconds), seconds > 0 {
                remotePlayerItem.duration = CMTimeMakeWithSeconds(seconds, preferredTimescale: 600)
            }
        }
    }
    
}
