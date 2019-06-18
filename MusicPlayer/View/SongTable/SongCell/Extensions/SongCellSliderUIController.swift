//
//  SongCellSliderController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 7/19/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

// TODO: Refactor SliderUI controller
private typealias SongCellSliderUIController = SongCell
extension SongCellSliderUIController {
    
    internal func resetSliderCAD() {
        if sliderCAD == nil {
            log.warning("sliderCAD is already nil, nothing to do")
            return
        }
        sliderCAD.invalidate()
        sliderCAD = nil
        songProgressSlider.value = 0
        songProgressSlider.isEnabled = false
    }

    internal func setupSliderCAD() {
        guard let audioPlayer = AudioPlayer.sharedInstance.player else {
            fatalError("Could not retrieve AudioPlayer instance")
        }
        songProgressSlider.isEnabled = true
        songProgressSlider.minimumValue = 0
        songProgressSlider.maximumValue = Float(audioPlayer.duration)
        sliderCAD = CADisplayLink(target: self, selector: #selector(self.updateSliderCAD))
        sliderCAD.preferredFramesPerSecond = 30
        sliderCAD.add(to: .current, forMode: RunLoop.Mode.default)
    }

    @objc internal func updateSliderCAD() {
        if let player = AudioPlayer.sharedInstance.player, sliderCAD != nil {
            songProgressSlider.value = Float(player.currentTime)
        }
    }
}
