//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/9/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIcons

protocol SongCellDelegate : class {
    func presentAlertForCell(alert: UIAlertController)
    func performSegueForCell(sender: Any?, identifier: String)
}

class SongCell: UITableViewCell {
    weak var delegate: SongCellDelegate!
    var song: SongEntity! {
        didSet {
            artistName.text = song.songArtist
            songTitle.text = song.songTitle
        }
    }
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var editSongButton: UIButton!
    @IBOutlet weak var moveSong: UIButton!
    @IBOutlet weak var songProgressSlider: UISlider!
    internal var updateSlider: CADisplayLink!

    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        //TODO: Change logic, don't depend on title
        if playPauseButton.title(for: .normal) == FontType.ionicons(.play).text {
            AudioPlayer.sharedInstance.playSong(song: song)
        } else {
            AudioPlayer.sharedInstance.pauseSong()
        }
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        //TODO: Change logic, don't depend on title
        if shuffleButton.title(for: .normal) == FontType.ionicons(.arrowReturnRight).text {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: systemColor, forState: .normal)
            AudioPlayer.sharedInstance.shuffleMode = true
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: systemColor, forState: .normal)
            AudioPlayer.sharedInstance.shuffleMode = false
        }
    }
    
    @IBAction func moveButtonTapped(_ sender: UIButton) {
        delegate.performSegueForCell(sender: song, identifier: "showPlaylistPicker")
    }

    @IBAction func changeSongNameTapped(_ sender: UIButton) {
        delegate.presentAlertForCell(alert: createChangeSongNameAlert())
    }
    
    @IBAction func changeSongPosition(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        AudioPlayer.sharedInstance.seekTo(position: songNewPosition)
    }
}

