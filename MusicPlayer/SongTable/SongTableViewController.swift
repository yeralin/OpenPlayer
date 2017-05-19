//
//  songTableView.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/23/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class SongTableViewController: UITableViewController {
    
    lazy var managedObjectContext: NSManagedObjectContext! = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    var playlist: PlaylistEntity!
    
    
    @IBOutlet var songTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        songTableView.allowsSelection = false
        self.title = playlist.playlistName
        initAudioPlayerDelegateImpl()
    }
    
    func getCell(atIndex: Int) -> SongCell {
        return songTableView.cellForRow(at: IndexPath(row: atIndex, section: 0)) as! SongCell
    }
    
    func prepareSongs(receivedPlaylist: PlaylistEntity) {
        playlist = receivedPlaylist
        let songsArray = SongPersistancyManager.sharedInstance.populateSongs(forPlaylist: receivedPlaylist,
                                                                             cntx: managedObjectContext!)
        AudioPlayer.sharedInstance.songsArray = songsArray
    }
    
}
