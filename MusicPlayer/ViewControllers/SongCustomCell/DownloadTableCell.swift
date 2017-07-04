//
//  DownloadTableCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

class DownloadTableCell: UITableViewCell, SongCell {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var songProgressSlider: UISlider!
    internal var updateSlider: CADisplayLink!
    weak var delegate: SongCellDelegate!
    
    var song: DownloadSongEntity!
    {
        didSet {
            artistName.text = song?.songArtist
            songTitle.text = song?.songTitle
        }
    }
    
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        actionOnPlayPauseTap()
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        actionOnShuffleTap()
    }
    
    @IBAction func moveTapped(_ sender: UIButton) {
        actionOnMoveTap()
    }
    @IBAction func changeSliderPosition(_ sender: UISlider) {
        actionOnChangeSliderPosition(sender)
    }
    
}
