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
        songProgressSlider.minimumValue = 0
        if let duration = StreamAudioPlayer.sharedInstance.duration {
            songProgressSlider.maximumValue = duration
        }
        songProgressSlider.isEnabled = true
        sliderCAD = CADisplayLink(target: self, selector: #selector(self.updateSliderCAD))
        sliderCAD.preferredFramesPerSecond = 60
        sliderCAD.add(to: .current, forMode: RunLoop.Mode.default)
    }
    
    @objc func updateSliderCAD() {
        if sliderCAD != nil {
            let player = StreamAudioPlayer.sharedInstance
            songProgressSlider.value = player.currentTime
            songProgressSlider.bufferEndValue = player.currentBufferValue
        }
    }
}
