//
//  SongTableCellSliderController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 7/19/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

private typealias SongCellSliderUIController = SongCell
extension SongCellSliderUIController {
    
    func setupSliderCAD() {
        songProgressSlider.isEnabled = true
        songProgressSlider.minimumValue = 0
        songProgressSlider.maximumValue = Float(AudioPlayer.sharedInstance.player.duration)
        sliderCAD = CADisplayLink(target: self, selector: #selector(self.updateSliderCAD))
        sliderCAD.preferredFramesPerSecond = 30
        sliderCAD.add(to: .current, forMode: RunLoop.Mode.default)
    }
    
    @objc func updateSliderCAD() {
        if let player = AudioPlayer.sharedInstance.player, sliderCAD != nil {
            songProgressSlider.value = Float(player.currentTime)
        }
    }
}
