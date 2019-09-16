//
//  SongEntity+CoreDataClass.swift
//  
//
//  Created by Daniyar Yeralin on 7/30/19.
//
//

import Foundation
import CoreData

@objc(SongEntity)
public class SongEntity: NSManagedObject {
    
    func isRemote() -> Bool {
        return self.songUrl != nil
    }
    
    func isCached() -> URL? {
        if let songName = self.songName {
            let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let localSongUrl = tempUrl.appendingPathComponent(songName).appendingPathExtension("mp3")
            if FileManager.default.fileExists(atPath: localSongUrl.relativePath) {
                return localSongUrl
            }
        }
        return nil
    }
    
    // Returns either remote http URL or local file URL
    func getSongUrl() -> URL {
        if self.isRemote(), let remoteSongUrl = self.songUrl {
            guard let cachedSongUrl = self.isCached() else {
                return remoteSongUrl
            }
            return cachedSongUrl
        } else {
            let songPerstManager = SongPersistencyManager.sharedInstance
            guard let localSongUrl = try? songPerstManager.getSongPath(song: self) else {
                fatalError("Could not locate the song: \(self)")
            }
            return localSongUrl
        }
    }
    
    
}
