//
//  DownloadTableCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/26/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    var highlightedTimer: Timer?
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var songProgressSlider: BufferSlider!
    internal var sliderCAD: CADisplayLink!
    weak var delegate: CellToTableDelegate!
    
    internal var song: SongEntity!
    {
        didSet {
            artistName.text = song?.songArtist
            songTitle.text = song?.songTitle
        }
    }
    
    override func awakeFromNib() {
        self.selectionStyle = .none
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
        songProgressSlider.bufferStartValue = 0
        songProgressSlider.bufferEndValue = 0
        songProgressSlider.maximumValue = 300 //temp value while not known duration
        songProgressSlider.isEnabled = false
    }
    
    func restorePlayingCell(song: SongEntity) {
        self.song = song
        playPauseButton.isSelected = true
        shuffleButton.isHidden = false
        shuffleButton.isSelected = AudioPlayer.instance.shuffleMode
        shuffleButton.isHidden = false
        restoreSliderCAD()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        self.actionOnPlayPauseTap(isPlaying: sender.isSelected,
                                  isInProgress: songProgressSlider.value != 0
                                    && songProgressSlider.isEnabled == true)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        actionOnShuffleTap(isShuffleMode: !sender.isSelected)
    }
    
    @IBAction func downloadTapped(_ sender: UIButton) {
        self.actionOnDownloadTap()
    }
    @IBAction func changeSliderPosition(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        self.actionOnChangeSliderPosition(position: songNewPosition)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
