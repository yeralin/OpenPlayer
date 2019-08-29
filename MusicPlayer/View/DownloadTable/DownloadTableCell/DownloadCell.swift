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
    
    internal func setShuffleButton() {
        shuffleButton.setIcon(icon: .ionicons(.arrowReturnRight), iconSize: 26,
                              color: .systemColor, forState: .normal)
        //shuffleButton.setIcon(icon: .ionicons(.shuffle), iconSize: 26,
        //                      color: .systemColor, forState: .normal)
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
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                color: .systemColor, forState: .normal)
        downloadButton.setIcon(icon: .ionicons(.iosCloudDownload), iconSize: 28,
                               color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = true
        songProgressSlider.value = 0
        songProgressSlider.bufferStartValue = 0
        songProgressSlider.bufferEndValue = 0
        songProgressSlider.maximumValue = 300 //temp value while not known duration
        songProgressSlider.isEnabled = false
    }
    
    func restorePlayingCell(song: SongEntity) {
        self.song = song
        
        if let player = AudioPlayer.instance.player, player.isPlaying {
            playPauseButton.setIcon(icon: .ionicons(.iosPause), iconSize: 23,
                                    color: .systemColor, forState: .normal)
        } else {
            playPauseButton.setIcon(icon: .ionicons(.play), iconSize: 24,
                                    color: .systemColor, forState: .normal)
        }
        downloadButton.setIcon(icon: .ionicons(.iosDownload), iconSize: 24,
                               color: .systemColor, forState: .normal)
        setShuffleButton()
        shuffleButton.isHidden = false
        setupSliderCAD()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        actionOnPlayPauseTapUI()
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        actionOnShuffleTapUI()
    }
    
    @IBAction func downloadTapped(_ sender: UIButton) {
        actionOnDownloadTapUI()
    }
    @IBAction func changeSliderPosition(_ sender: UISlider) {
        actionOnChangeSliderPositionUI(sender)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
