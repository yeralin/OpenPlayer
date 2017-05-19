//
//  MoveToPickerViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

protocol MoveToPickerViewDelegate : class {
    func songMovedPlaylist(song: SongEntity, toPlaylist: PlaylistEntity)
}


class MoveToPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: MoveToPickerViewDelegate!
    @IBOutlet weak var playlistPicker: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    var playlistArray = [PlaylistEntity]()
    var songToMove: SongEntity!
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        if playlistArray.count != 0 {
            let selectedPlaylistIndex = playlistPicker.selectedRow(inComponent: 0)
            let toPlaylist = playlistArray[selectedPlaylistIndex]
            delegate.songMovedPlaylist(song: songToMove, toPlaylist: toPlaylist)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerToolbar.clipsToBounds = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //let playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: managedObjectContext)
        return playlistArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //let playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: managedObjectContext)
        return playlistArray[row].playlistName
    }
}
