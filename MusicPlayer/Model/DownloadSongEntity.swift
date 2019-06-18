//
//  DownloadSongEntity+CoreDataClass.swift
//  
//
//  Created by Daniyar Yeralin on 6/14/19.
//
//

import Foundation
import CoreData

/* Not NSManagedObject entity
 Attemped to extend it from SongEntity,
 but became to hacky to support since NSManagedObject entities
 require context to be defined
 DownloadSongEntity is not saved in CoreData
*/
public class DownloadSongEntity {
    
    public var songTitle: String?
    public var songArtist: String?
    public var songName: String?
    public var songArtwork: Data?
    public var songUrl: URL?
    
    init(songTitle: String, songArtist: String, songName: String, songUrl: URL) {
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.songName = songName
        self.songUrl = songUrl
    }
    
    static func == (left: DownloadSongEntity, right: DownloadSongEntity) -> Bool {
        let titleEq = (left.songTitle == right.songTitle)
        let artistEq = (left.songArtist == right.songArtist)
        let urlEq = (left.songUrl == right.songUrl)
        return titleEq && artistEq && urlEq
    }
}
