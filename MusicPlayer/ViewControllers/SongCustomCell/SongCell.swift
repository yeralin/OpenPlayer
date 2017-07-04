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
    func presentAlertForCell(alert: UIAlertController, alertName: String)
    func performSegueForCell(sender: Any?, identifier: String)
}

protocol SongCell {
    
    associatedtype SongEntityType
    
    //Tap actions
    func actionOnPlayPauseTap()
    func actionOnShuffleTap()
    func actionOnMoveTap()
    func actionOnChangeSongNameTap()
    func actionOnChangeSliderPosition(_ sender: UISlider)
    
    //States
    func initCell(initSong: SongEntityType)
    func restorePlayingCell(song: SongEntityType)
    func playSongCellState()
    func pauseSongCellState()
    func resetSongCellState()
    func setupUpdateSlider()
}

