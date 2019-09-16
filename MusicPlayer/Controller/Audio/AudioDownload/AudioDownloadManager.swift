//
//  AudioDownloadManager.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 8/29/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation

class AudioDownloadManager {
    
    internal class AudioDownloadPair {
        
        var remotePlayerItem: RemotePlayerItem
        var targetPlaylist: PlaylistEntity
        
        init(remotePlayerItem: RemotePlayerItem, targetPlaylist: PlaylistEntity) {
            self.remotePlayerItem = remotePlayerItem
            self.targetPlaylist = targetPlaylist
        }
    }
    
    internal var downloadQueue: [AudioDownloadPair] = []
    internal var active: AudioDownloadPair?
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remotePlayerItemFinishedDownloading(_:)),
                                               name: .downloadFinished, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func append(toDownload remotePlayerItem: RemotePlayerItem, toPlaylist targetPlaylist: PlaylistEntity) {
        let toAppendPair = AudioDownloadPair(remotePlayerItem: remotePlayerItem, targetPlaylist: targetPlaylist)
        downloadQueue.append(toAppendPair)
        offer(toAppendPair)
    }
    
    private func offer(_ audioDownloadPair: AudioDownloadPair) {
        if active != nil {
            audioDownloadPair.remotePlayerItem.downloadWithoutPlay()
            active = audioDownloadPair
        }
    }
    
    @objc internal func remotePlayerItemFinishedDownloading(_ notification: Notification) {
        guard let remotePlayerItem = notification.object as? RemotePlayerItem,
            let songName = remotePlayerItem.assignedSong.songName else {
                log.debug("Could not properly handle a notification: \(notification)")
                return
        }
        var songDestUrl: URL
        do {
            if let active = self.active,
                remotePlayerItem == active.remotePlayerItem {
                let targetPlaylistPath = try PlaylistPersistencyManager.sharedInstance
                    .getPlaylistPath(playlist: active.targetPlaylist)
                songDestUrl = targetPlaylistPath
                    .appendingPathComponent(songName)
                    .appendingPathExtension("mp3")
                self.active = nil
                if let nextCandidate = downloadQueue.count > 0 ? downloadQueue.remove(at: 0) : nil {
                    offer(nextCandidate)
                }
            } else {
                let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                songDestUrl = tempUrl
                    .appendingPathComponent(songName)
                    .appendingPathExtension("mp3")
            }
            try remotePlayerItem.payload?.write(to: songDestUrl, options: .atomic)
        } catch let error {
            log.error("Failed handling finished downloading event \(error.localizedDescription)")
        }
        
    }
}
