//
//  DownloadTableCellSliderController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 7/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

private typealias DownloadTableCellSliderController = DownloadTableCell
extension DownloadTableCellSliderController {
    
    func resetSliderCAD() {
        if sliderCAD != nil {
            sliderCAD.invalidate()
            sliderCAD = nil
            songProgressSlider.value = 0
            songProgressSlider.isEnabled = false
        }
    }
    
    func setupSliderCAD() {
        if let player = StreamAudioPlayer.sharedInstance.player {
            songProgressSlider.minimumValue = 0
            let duration = player.duration.seconds
            if duration.isNaN {
                songProgressSlider.maximumValue = Float(300)
                songProgressSlider.isEnabled = false
            } else {
                songProgressSlider.maximumValue = Float(duration)
                songProgressSlider.isEnabled = true
            }
            sliderCAD = CADisplayLink(target: self, selector: #selector(self.updateSliderCAD))
            sliderCAD.preferredFramesPerSecond = 60
            sliderCAD.add(to: .current, forMode: .defaultRunLoopMode)
        }
    }
    
    func enableSliderCAD(duration: Float64) {
        songProgressSlider.maximumValue = Float(duration)
        songProgressSlider.isEnabled = true
    }
    
    func updateSliderCAD() {
        if let player = StreamAudioPlayer.sharedInstance.player, sliderCAD != nil {
            songProgressSlider.value = Float(player.currentTime().seconds)
        }
    }
}
