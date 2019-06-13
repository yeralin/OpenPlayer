//
//  StreamAudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//
import MediaPlayer

protocol StreamAudioPlayerDelegate : class {
    func cellState(state: PlayerState, song: DownloadSongEntity)
    func getSongArray() -> [DownloadSongEntity]
}

class StreamAudioPlayer: NSObject, CachingPlayerItemDelegate {
    
    var player: AVPlayer!
    var songsArray: [DownloadSongEntity]?
    var currentSong: DownloadSongEntity?
    var shuffleMode: Bool = false
    var rc: RemoteControl!
    var currentBufferValue: Double = 0
    weak var delegate: StreamAudioPlayerDelegate!
    var duration: Float? {
        get {
            if let duration = self.player.currentItem?.asset.duration.seconds {
                return Float(duration)
            } else {
                return nil
            }
        }
    }
    var currentTime: Float {
        get {
            if self.player != nil {
                return Float(self.player.currentTime().seconds)
            } else {
                return Float(-1)
            }
        }
    }
    
    static let sharedInstance = StreamAudioPlayer()
    
    override init() {
        super.init()
        if rc != nil {
            rc.resetMPControls()
        }

        rc = RemoteControl.init(resumeSong: resumeSong,
                pauseSong: pauseSong,
                playNextSong: playNextSong,
                playPreviousSong: playPreviousSong,
                seekFor: seekFor(seconds:forward:))
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
    
    func playSong(song: DownloadSongEntity) {
        if player != nil && !player.isPlaying && song == currentSong! {
            resumeSong()
        } else {
            self.stopSong()
            AudioPlayer.sharedInstance.stopSong()
            currentSong = song
            let playerItem = CachingPlayerItem(url: song.songUrl!)
            /*NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playNextSong),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)*/
            playerItem.delegate = self
            player = AVPlayer(playerItem: playerItem)
            player.automaticallyWaitsToMinimizeStalling = false
            player.play()
            delegate.cellState(state: .prepare, song: currentSong!)
            rc.setMPControls(songArtist: song.songArtist!, songTitle: song.songTitle!)
        }
    }
    
    func resumeSong() {
        if let song = currentSong {
            if player == nil {
                playSong(song: song)
            }
            player.play()
            delegate?.cellState(state: .resume,song: song)
            rc.updateMP(state: .resume, currentTime: player.currentTime().seconds)
        }
        
    }
    
    func stopSong() {
        if player != nil {
            if let song = currentSong {
                //player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
                player.pause()
                player.currentItem?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                player = nil
                delegate?.cellState(state: .stop,song: song)
                rc.resetMPControls()
            }
        }
    }
    
    func pauseSong() {
        if player != nil && player.isPlaying {
            if let song = currentSong {
                delegate?.cellState(state: .pause, song: song)
                player.pause()
                rc.updateMP(state: .pause)
            }
        }
    }
    
    func seekFor(seconds: Double, forward: Bool) {
        if player != nil, let currentTime = player.currentItem?.currentTime() {
            let cmTime = CMTime(seconds: seconds, preferredTimescale: 1000000)
            let seekTo = forward ? currentTime + cmTime : currentTime - cmTime
            player.currentItem?.seek(to: seekTo)
            rc.updateMP(state: .resume, currentTime: player.currentTime().seconds)
        }
    }
    
    func seekTo(position: TimeInterval) {
        if player != nil {
            let cmTime = CMTime(seconds: position, preferredTimescale: 1000000)
            player.currentItem?.seek(to: cmTime)
            rc.updateMP(state: .resume, currentTime: player.currentTime().seconds)
        }
    }
    
    func playPreviousSong() {
        var prevSong = 0
        if  let song = currentSong, let songsArray = self.songsArray {
            if shuffleMode == true {
                prevSong = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                prevSong = songsArray.firstIndex(where: {$0 == song})! - 1
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
        if let song = currentSong, let songsArray = self.songsArray {
            if shuffleMode == true {
                nextSong = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                nextSong = songsArray.firstIndex(where: {$0 == song})! + 1
            }
            if songsArray.indices.contains(nextSong) {
                self.playSong(song: songsArray[nextSong])
            } else {
                stopSong()
            }
        }
    }
    
    func getCurrentTimeAsString() -> String {
        return ""
    }
    
    //Delegate methods
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        log.info("Finished downloading")
        if let songName = currentSong?.songName {
            let docsUrl = SongPersistencyManager.sharedInstance.docsUrl
            let downloadsDir = docsUrl.appendingPathComponent("Downloads")
            let dest = downloadsDir.appendingPathComponent(songName).appendingPathExtension("mp3")
            do {
                log.info("Writing to a file: \(dest)")
                try data.write(to: dest, options: .atomic)
            } catch {
                log.error("Failed writing file to \(dest)\nError: " + error.localizedDescription)
            }
        }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        log.info("Loaded so far: \(bytesDownloaded) out of \(bytesExpected)")
        currentBufferValue = Double(bytesDownloaded/(bytesExpected/100))/100
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        log.info("Ready to play...")
        let duration = playerItem.asset.duration.seconds
        rc.updateMPDuration(duration: duration)
        delegate.cellState(state: .play, song: currentSong!)
        player.play()
    }
    
    func playerItemDidStopPlayback(playerItem: CachingPlayerItem) {
        log.info("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        delegate.cellState(state: .prepare, song: currentSong!)
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        log.error("The streaming has failed due to: \(error)")
        delegate.cellState(state: .stop, song: currentSong!)
    }
    
}
