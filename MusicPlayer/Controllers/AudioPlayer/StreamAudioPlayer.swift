//
//  StreamAudioPlayer.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/28/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import MediaPlayer

extension AVPlayer {
    var isPlaying: Bool {
        get {
            return rate != 0 && error == nil
        }
    }
    var duration: CMTime {
        get {
            return self.currentItem!.duration
        }
    }
}

class StreamAudioPlayer: NSObject, AudioPlayerProtocol, CachingPlayerItemDelegate {
    
    typealias PlayerType = AVPlayer
    var player: AVPlayer!
    var songsArray: [DownloadSongEntity] = []
    var currentSong: DownloadSongEntity?
    var shuffleMode: Bool = false
    var rc: RemoteControl!
    weak var delegate: AudioPlayerDelegate!
    
    static let sharedInstance = StreamAudioPlayer()
    
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
    
    func playSong(song: DownloadSongEntity) {
        if player != nil && !player.isPlaying && song == currentSong! {
            resumeSong()
        } else {
            self.stopSong()
            AudioPlayer.sharedInstance.stopSong()
            currentSong = song
            let songUrl = song.songUrl!
            let playerItem = CachingPlayerItem(url: songUrl)
            playerItem.addObserver(self,
                                   forKeyPath: #keyPath(AVPlayerItem.duration),
                                   options: [.old, .new],
                                   context: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playNextSong),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            playerItem.delegate = self
            player = AVPlayer(playerItem: playerItem)
            delegate.cellState(state: State.prepare, song: currentSong!)
            rc.updateMPControls(player: player, currentSong: currentSong!)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.duration) {
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = kCMTimeZero
            }
            let validDuration = newDuration.isNumeric && newDuration.value != 0
            let duration = validDuration ? CMTimeGetSeconds(newDuration) : 0.0
            if duration != 0 {
                delegate.cellState(state: .play, song: currentSong!)
                rc.updateMPDuration(duration: duration)
            }
        }
    }
    
    func playerItemReadyToPlay(playerItem: CachingPlayerItem) {
        player.play()
        playerItem.download()
    }
    
    
    func playerItemDidStopPlayback(playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(playerItem: CachingPlayerItem, didFinishDownloadingData data: NSData) {
        do {
            print("Finished")
            if let songName = currentSong?.songName {
                let tempDirectory = FileManager.default.temporaryDirectory
                let audioFile = tempDirectory.appendingPathComponent(songName).appendingPathExtension("mp3")
                try data.write(to: audioFile, options: .atomic)
                let durationFlags = player.currentItem?.asset.duration.flags
                if durationFlags!.contains(.indefinite) {
                    //If streamed song did not provide Content-Length header
                    //duration is unknown, replacing stream with downloaded song
                    NotificationCenter.default.removeObserver(self,
                                                              name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                              object: playerItem)
                    playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
                    let currentTime = player.currentTime()
                    let replaceItem = AVPlayerItem(url: audioFile)
                    replaceItem.addObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.duration),
                                           options: [.old, .new],
                                           context: nil)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(playNextSong),
                                                           name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                           object: replaceItem)
                    player.replaceCurrentItem(with: replaceItem)
                    player.seek(to: currentTime)
                    rc.updateMPTime(state: State.resume, player: player)
                }
            }
        } catch {
            log.error(error)
        }
    }
    
    func resumeSong() {
        if let song = currentSong {
            if player == nil {
                playSong(song: song)
            }
            player.play()
            delegate?.cellState(state: State.resume,song: song)
            rc.updateMPTime(state: State.resume, player: player)
        }
        
    }
    
    func stopSong() {
        if player != nil {
            if let song = currentSong {
                player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
                player.pause()
                player.currentItem?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                player = nil
                delegate?.cellState(state: State.stop,song: song)
                rc.updateMPTime(state: State.stop, player: player)
            }
        }
    }
    
    func pauseSong() {
        if player != nil && player.isPlaying {
            if let song = currentSong {
                delegate?.cellState(state: State.pause, song: song)
                player.pause()
                rc.updateMPTime(state: State.pause, player: player)
            }
        }
    }
    
    
    
    func seekTo(position: CMTime) {
        if player != nil {
            player.currentItem?.seek(to: position)
            rc.updateMPTime(state: State.resume, player: player)
        }
    }
    
    func playPreviousSong() {
        var prevSong = 0
        if let song = currentSong {
            if shuffleMode == true {
                prevSong = Int(arc4random_uniform(UInt32(songsArray.count)))
            } else {
                prevSong = songsArray.index(where: {$0 == song})! - 1
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
                nextSong = songsArray.index(where: {$0 == song})! + 1
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
}
