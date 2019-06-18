//
//  DownloadCellSliderUIController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 7/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

private typealias DownloadCellSliderUIController = DownloadCell
extension DownloadCellSliderUIController {
    
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
        songProgressSlider.minimumValue = 0
        if let duration = StreamAudioPlayer.sharedInstance.duration {
            songProgressSlider.maximumValue = duration
        }
        songProgressSlider.isEnabled = true
        sliderCAD = CADisplayLink(target: self, selector: #selector(self.updateSliderCAD))
        sliderCAD.preferredFramesPerSecond = 60
        sliderCAD.add(to: .current, forMode: RunLoop.Mode.default)
    }
    
    @objc internal  func updateSliderCAD() {
        if sliderCAD != nil {
            let player = StreamAudioPlayer.sharedInstance
            songProgressSlider.value = player.currentTime
            songProgressSlider.bufferEndValue = player.currentBufferValue
        } else {
            log.error("Could not update slider CAD")
        }
    }
}
