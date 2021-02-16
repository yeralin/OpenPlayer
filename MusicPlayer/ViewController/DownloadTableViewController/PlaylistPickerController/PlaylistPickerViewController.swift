//
//  MoveSongPickerViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/18/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

protocol PlaylistPickerDelegate : class {
    func moveSong(songCell: BaseCell, toPlaylist: PlaylistEntity)
}


class PlaylistPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: PlaylistPickerDelegate!
    @IBOutlet weak var playlistPicker: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    var playlistArray = [PlaylistEntity]()
    var songCellToMove: BaseCell!
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        if playlistArray.count != 0 {
            let selectedPlaylistIndex = playlistPicker.selectedRow(inComponent: 0)
            let toPlaylist = playlistArray[selectedPlaylistIndex]
            delegate.moveSong(songCell: songCellToMove, toPlaylist: toPlaylist)
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
        return playlistArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return playlistArray[row].playlistName
    }
}
