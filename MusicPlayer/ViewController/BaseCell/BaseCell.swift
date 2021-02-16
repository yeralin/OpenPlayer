//
//  BaseCell.swift
//  MusicPlayer
//
//  Created by Yeralin, Daniyar on 2/26/21.
//  Copyright © 2021 Daniyar Yeralin. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {
    
    // Internal constants
    internal let ARTIST_TEXT_FIELD_INDEX: Int = 0
    internal let TITLE_TEXT_FIELD_INDEX: Int = 1
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    weak var delegate: CellToTableDelegate!
    
    var rowIndex: Int!
    
    var song: SongEntity! {
        didSet {
            artistName.text = song.songArtist
            songTitle.text = song.songTitle
        }
    }
}
