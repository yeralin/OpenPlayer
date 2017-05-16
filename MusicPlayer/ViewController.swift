//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/19/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import SwiftIconFont

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}



class AudioPlayer : NSObject, AVAudioPlayerDelegate {
    var player : AVAudioPlayer!
    weak var delegate : AVAudioPlayerDelegate?
    func playFile(atPath path:String) {
        self.player?.delegate = nil
        self.player?.stop()
        let fileURL = URL(fileURLWithPath: path)
        guard let p = try? AVAudioPlayer(contentsOf: fileURL) else {
            return
        }
        self.player = p
    }
    
}

class PlaylistTableView: UITableViewDelegate, UITableViewDataSource {
    
    var playlistArray = [URL]()
    let APlayerCntrl = AudioPlayer()
    let fm = FileManager.default
    
    @IBOutlet weak var playlistTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scc = MPRemoteCommandCenter.shared()
        scc.playCommand.addTarget(self, action:#selector(doPlay))
        scc.pauseCommand.addTarget(self, action:#selector(doPause))
        scc.togglePlayPauseCommand.addTarget(self, action: #selector(doPlayPause))
        /*APlayerCntrl.playFile(atPath: Bundle.main.path(forResource: "1", ofType: "wav")!)
        APlayerCntrl.player.prepareToPlay()
        APlayerCntrl.player.play()*/
        
        
        let docsurl = try? fm.url(for:.documentDirectory,
                                 in: .userDomainMask, appropriateFor: nil, create: false)
        let myfolder = docsurl?.appendingPathComponent("MyFolder")
        try? fm.createDirectory(at:myfolder!, withIntermediateDirectories: true)
        
        let contentsArray = try! fm.contentsOfDirectory(at:docsurl!,
                                             includingPropertiesForKeys: nil)
        var isDir : ObjCBool = false
        contentsArray.forEach {
            entry in
            if fm.fileExists(atPath: entry.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    playlistArray.append(entry)
                }
            }

        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTable.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        cell.textLabel?.text = playlistArray[indexPath.row].lastPathComponent
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    deinit {
        let scc = MPRemoteCommandCenter.shared()
        scc.togglePlayPauseCommand.removeTarget(self)
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
    }
    
    func doPlayPause(_ event:MPRemoteCommandEvent) {
        let p = self.APlayerCntrl.player
        if (p?.isPlaying)! { p!.pause() } else { p!.play() }
    }
    func doPlay(_ event:MPRemoteCommandEvent) {
        let p = self.APlayerCntrl.player
        p!.play()
    }
    
    func doPause(_ event:MPRemoteCommandEvent) {
        let p = self.APlayerCntrl.player
        p!.pause()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
