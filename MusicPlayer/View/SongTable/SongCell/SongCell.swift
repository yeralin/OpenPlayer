//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    
    // Internal constants
    internal let ARTIST_TEXT_FIELD_INDEX: Int = 0
    internal let TITLE_TEXT_FIELD_INDEX: Int = 1
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var songProgressSlider: UISlider!
    internal var sliderCAD: CADisplayLink!
    weak var delegate: CellToTableDelegate!

    internal var song: LocalSongEntity! {
        didSet {
            artistName.text = song.songArtist
            songTitle.text = song.songTitle
        }
    }

    internal func setShuffleButton() {
        if AudioPlayer.sharedInstance.shuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
        }
    }

    func initCell(initSong: LocalSongEntity) {
        self.song = initSong
        if sliderCAD != nil {
            sliderCAD.invalidate()
        }
        sliderCAD = nil
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
        editButton.setIcon(icon: .ionicons(.edit), iconSize: 24, color: .systemColor, forState: .normal)
        moveButton.setIcon(icon: .ionicons(.folder), iconSize: 28, color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = true
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }

    func restorePlayingCell(song: LocalSongEntity) {
        self.song = song
        if let player = AudioPlayer.sharedInstance.player {
            if player.isPlaying {
                playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 23, color: .systemColor, forState: .normal)
            } else {
                playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24, color: .systemColor, forState: .normal)
            }
            editButton.setIcon(icon: .ionicons(.edit), iconSize: 24, color: .systemColor, forState: .normal)
            moveButton.setIcon(icon: .ionicons(.folder), iconSize: 24, color: .systemColor, forState: .normal)
            setShuffleButton()
            shuffleButton.isHidden = false
            setupSliderCAD()
        }
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        actionOnPlayPauseTapUI()
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        actionOnShuffleTapUI()
    }
    
    @IBAction func moveTapped(_ sender: UIButton) {
        actionOnMoveTapUI()
    }
    
    @IBAction func changeSongNameTapped(_ sender: UIButton) {
        actionOnChangeSongNameTapUI()
    }
    
    @IBAction func changeSliderPosition(_ sender: UISlider) {
        actionOnChangeSliderPositionUI(sender)
    }
    
}
