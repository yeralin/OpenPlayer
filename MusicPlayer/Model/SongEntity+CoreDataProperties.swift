//
//  SongEntity+CoreDataProperties.swift
//  
//
//  Created by Daniyar Yeralin on 7/30/19.
//
//

import Foundation
import CoreData


extension SongEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SongEntity> {
        return NSFetchRequest<SongEntity>(entityName: "SongEntity")
    }

    @NSManaged public var isProcessed: Bool
    @NSManaged public var songArtist: String?
    @NSManaged public var songArtwork: NSData?
    @NSManaged public var songName: String?
    @NSManaged public var songOrder: Int32
    @NSManaged public var songTitle: String?
    @NSManaged public var songUrl: URL?
    @NSManaged public var playlist: PlaylistEntity?

}
