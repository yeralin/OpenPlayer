//
//  DownloadCellSliderUIController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 7/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

// MARK: Download cell slider UI controller
extension DownloadCell {
    
    internal func resetSliderCAD() {
        if sliderCAD == nil {
            log.warning("sliderCAD is already nil, nothing to do")
            return
        }
        sliderCAD.invalidate()
        sliderCAD = nil
        songProgressSlider.value = 0
        songProgressSlider.bufferEndValue = 0
        songProgressSlider.isEnabled = false
    }
    
    internal func setupSliderCAD() {
        if let duration = AudioPlayer.instance.player?.duration {
            songProgressSlider.minimumValue = 0
            songProgressSlider.maximumValue = Float(duration)
            songProgressSlider.isEnabled = true
            sliderCAD = CADisplayLink(target: self, selector: #selector(self.updateSliderCAD))
            sliderCAD.preferredFramesPerSecond = 60
            sliderCAD.add(to: .current, forMode: RunLoop.Mode.default)
        } else {
            log.warning("Could not setup slider because duration is not yet known")
        }
    }
    
    @objc internal  func updateSliderCAD() {
        if sliderCAD != nil,
            let currentTime = AudioPlayer.instance.player?.currentTime,
            let currentPlayerItem = AudioPlayer.instance.currentPlayerItem {
            songProgressSlider.value = currentTime
            songProgressSlider.bufferEndValue = currentPlayerItem.bufferValue
        } else {
            log.error("Could not update slider CAD")
        }
    }
}
