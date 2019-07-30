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
}
