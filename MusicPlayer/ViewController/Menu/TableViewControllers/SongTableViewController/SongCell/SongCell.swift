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

    internal var song: SongEntity! {
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
        playPauseButton.isSelected = false
        shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
        shuffleButton.isHidden = true
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }

    func restorePlayingCell(song: SongEntity) {
        self.song = song
        playPauseButton.isSelected = AudioPlayer.instance.isPlaying()
        shuffleButton.isHidden = false
        shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
        restoreSliderCAD()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        actionOnPlayPauseTap(isPlaying: sender.isSelected,
                             isInProgress: songProgressSlider.value != 0
                                && songProgressSlider.isEnabled == true)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        actionOnShuffleTap(isShuffleMode: !sender.isSelected)
        sender.isSelected = AudioPlayer.instance.shuffleMode
    }
    
    @IBAction func moveTapped(_ sender: UIButton) {
        delegate.performSegueForCell(sender: song, identifier: Constants.PRESENT_PLAYLIST_PICKER)
    }
    
    @IBAction func changeSongNameTapped(_ sender: UIButton) {
        delegate.presentAlertForCell(alert: changeSongNameAlert(), alertName: Constants.PRESENT_CHANGE_SONG_NAME_ALERT)
    }
    
    @IBAction func changeSliderPosition(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        actionOnChangeSliderPosition(songNewPosition: songNewPosition)
    }
    
}
