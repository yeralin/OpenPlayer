//
//  MoveSongToPlaylistExtention.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/9/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias MoveToPlaylistPicker = SongTableViewController
extension MoveToPlaylistPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MoveSongToPlaylist Picker Delegate methods
    func initMoveSongToPlaylistPicker() {
        super.viewDidLoad()
        createMoveSongToPlaylistPicker()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: managedObjectContext)
        return playlistArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: managedObjectContext)
        return playlistArray[row].playlistName
    }
    
    
    func createMoveSongToPlaylistPicker() {
        let pickerHeight = self.view.frame.height/3
        let pickerWidth = self.view.frame.width
        //let pickerYpos = (self.view.frame.height - pickerHeight) - 64
        songToMoveModalView = UIView(frame:CGRect(x: 0, y: self.view.frame.height, width: pickerWidth, height: pickerHeight))
        moveSongToPlaylistPicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: pickerWidth, height: pickerHeight))
        moveSongToPlaylistPicker.showsSelectionIndicator = true
        moveSongToPlaylistPicker.delegate = self
        moveSongToPlaylistPicker.dataSource = self
        moveSongToPlaylistPicker.backgroundColor = UIColor.white
        
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: pickerWidth, height: 40.0))
        
        toolBar.tintColor = self.view.tintColor
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(hideMoveSongToPlaylistPicker))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(performMoveSongToPlaylist))
        
        let titleFakeButton = UIBarButtonItem(title: "Move to", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        titleFakeButton.tintColor = .black
        titleFakeButton.isEnabled = false
        titleFakeButton.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold),NSForegroundColorAttributeName: UIColor.black], for: .normal)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([cancelButton,flexSpace,titleFakeButton,flexSpace,doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        songToMoveModalView.addSubview(moveSongToPlaylistPicker)
        songToMoveModalView.addSubview(toolBar)
        
    }
    
    func showMoveSongToPlaylistPicker(toMove: SongCell) {
        songToMoveCell = toMove
        self.view.addSubview(songToMoveModalView)
        UIView.animate(withDuration: 0.3, animations: {
            let pickerHeight = self.view.frame.height/3
            let pickerWidth = self.view.frame.width
            let pickerYpos = (self.view.frame.height - pickerHeight) - 64
            self.songToMoveModalView.frame = CGRect(x: 0, y: pickerYpos, width: pickerWidth, height: pickerHeight)
        })
    }
    
    func performMoveSongToPlaylist() {
        let playlistArray = PlaylistPersistancyManager.sharedInstance.getPlaylistArray(cntx: managedObjectContext)
        let toPlaylist: PlaylistEntity = playlistArray[moveSongToPlaylistPicker.selectedRow(inComponent: 0)]
        
        hideMoveSongToPlaylistPicker()
    }
    
    func hideMoveSongToPlaylistPicker() {
        songToMoveCell = nil
        UIView.animate(withDuration: 0.3, animations: {
            let pickerHeight = self.view.frame.height/3
            let pickerWidth = self.view.frame.width
            self.songToMoveModalView.frame = CGRect(x: 0, y: self.view.frame.height, width: pickerWidth, height: pickerHeight)
        }, completion: { completed in
            if completed {
                self.songToMoveModalView.removeFromSuperview()
            }
        })
        
    }
}
