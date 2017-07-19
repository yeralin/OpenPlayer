//
//  SongTableCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

class SongTableCell: UITableViewCell, SongCell {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var songProgressSlider: UISlider!
    internal var sliderCAD: CADisplayLink!
    weak var delegate: SongCellDelegate!
    
    var song: SongEntity! {
        didSet {
            artistName.text = song.songArtist
            songTitle.text = song.songTitle
        }
    }
    
    func initCell(initSong: SongEntity) {
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
    
    func restorePlayingCell(song: SongEntity) {
        self.song = song
        let audioPlayer = AudioPlayer.sharedInstance
        if audioPlayer.player.isPlaying {
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
    
    func setShuffleButton() {
        if AudioPlayer.sharedInstance.shuffleMode {
            shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26, color: .systemColor, forState: .normal)
        } else {
            shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26, color: .systemColor, forState: .normal)
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
    
    @IBAction func changeSongNameTapped(_ sender: UIButton) {
        actionOnChangeSongNameTap()
    }
    
    @IBAction func changeSliderPosition(_ sender: UISlider) {
        actionOnChangeSliderPosition(sender)
    }
    
}
