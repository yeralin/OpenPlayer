//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/9/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIconFont

class SongCell: UITableViewCell {
    
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
    internal var updateSlider: CADisplayLink! = nil
    
    internal final var playIcon: String = "play"
    internal final var pauseIcon: String = "ios-pause"
    internal final var nextIcon: String = "arrow-return-right"
    internal final var shuffleIcon: String = "shuffle"
    internal final var editIcon: String = "edit"
    internal final var folderIcon: String = "ios-folder"
    
    func initCell(initSong: SongEntity) {
        self.song = initSong
        shuffleButton.isHidden = true
    }
    
    func restorePlayingCell(song: SongEntity) {
        self.song = song
        let audioPlayer = AudioPlayer.sharedInstance
        if audioPlayer.player.isPlaying {
            playPauseButton.setIconWithSize(icon: pauseIcon, font: .Ionicon, size: 24)
        } else {
            playPauseButton.setIconWithSize(icon: playIcon, font: .Ionicon, size: 24)
        }
        shuffleButton.isHidden = false
        if audioPlayer.shuffleMode {
            shuffleButton.setIconWithSize(icon: shuffleIcon, font: .Ionicon, size: 26)
        } else {
            shuffleButton.setIconWithSize(icon: nextIcon, font: .Ionicon, size: 26)
        }
        setupUpdateSlider()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moveSong.setTitle(String.fontIonIcon(folderIcon), for: .normal)
        playPauseButton.setIconWithSize(icon: playIcon, font: .Ionicon, size: 24)
        editSongButton.setIconWithSize(icon: editIcon, font: .Ionicon, size: 24)
        moveSong.setIconWithSize(icon: folderIcon, font: .Ionicon, size: 22)
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if playPauseButton.title(for: .normal) == String.fontIonIcon(playIcon) {
            AudioPlayer.sharedInstance.playSong(song: song)
        } else {
            AudioPlayer.sharedInstance.pauseSong()
        }
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        if shuffleButton.title(for: .normal) == String.fontIonIcon(nextIcon) {
            shuffleButton.setIconWithSize(icon: shuffleIcon, font: .Ionicon, size: 26)
            AudioPlayer.sharedInstance.shuffleMode = true
        } else {
            shuffleButton.setIconWithSize(icon: nextIcon, font: .Ionicon, size: 26)
            AudioPlayer.sharedInstance.shuffleMode = false
        }
    }
    
    @IBAction func moveButtonTapped(_ sender: UIButton) {
        (self.parentViewController as! SongTableViewController).showMoveSongToPlaylistPicker(toMove: self)
    }

    @IBAction func changeSongNameTapped(_ sender: UIButton) {
        self.parentViewController!.present(createChangeSongNameAlert(), animated: true, completion: nil)
    }
    
    @IBAction func changeSongPosition(_ sender: UISlider) {
        let songNewPosition = TimeInterval(sender.value)
        AudioPlayer.sharedInstance.seekTo(position: songNewPosition)
    }
    
    func setupUpdateSlider() {
        songProgressSlider.isEnabled = true
        songProgressSlider.minimumValue = 0
        songProgressSlider.maximumValue = Float(AudioPlayer.sharedInstance.player.duration)
        updateSlider = CADisplayLink(target: self, selector: #selector(self.updateAudioSlider))
        updateSlider.preferredFramesPerSecond = 60
        updateSlider.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    func updateAudioSlider() {
        let player = AudioPlayer.sharedInstance.player!
        songProgressSlider.value = Float(player.currentTime)
    }
    
    
    
}

