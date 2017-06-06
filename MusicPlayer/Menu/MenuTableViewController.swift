//
//  MenuTableViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/29/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIcons
//import GCDWebServer

class MenuCell: UITableViewCell {
    @IBOutlet weak var menuIcon: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switch menuLabel.text! {
        case "Playlists":
            menuIcon.setIcon(icon: FontType.ionicons(.iosMusicalNotes),
                             iconSize: 28, color: systemColor, bgColor: .clear)
        case "Download":
            menuIcon.setIcon(icon: FontType.ionicons(.iosSearchStrong),
                             iconSize: 25, color: systemColor, bgColor: .clear)
        case "Server":
            menuIcon.setIcon(icon: FontType.ionicons(.iosCloud),
                             iconSize: 25, color: systemColor, bgColor: .clear)
        case "Settings":
            menuIcon.setIcon(icon: FontType.ionicons(.iosGear),
                             iconSize: 25, color: systemColor, bgColor: .clear)
        default:
            menuIcon.text = "???"
        }
    }
}

class MenuTableViewController: UITableViewController {
    
    //var webUploader: GCDWebUploader? = nil
    
    
   /*@IBAction func serverSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let documentsPath: String? = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            webUploader = GCDWebUploader(uploadDirectory: documentsPath)
            webUploader!.start()
            address.text = webUploader?.serverURL.absoluteString
        } else {
            webUploader?.stop()
        }
        
    }*/
    
    var currentView: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationController?.hidesBarsOnTap = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "presentPlaylistTableView", sender: nil)
    }
    
    
    
    
}
