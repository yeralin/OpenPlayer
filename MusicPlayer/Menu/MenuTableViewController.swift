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
    }
}

class MenuTableViewController: UITableViewController {
    
    let menuLabels = [("Playlists", FontType.ionicons(.iosMusicalNotes), 28),
                      ("Download", FontType.ionicons(.iosSearchStrong), 25),
                      ("Server", FontType.ionicons(.iosCloud), 25),
                      ("Settings", FontType.ionicons(.iosGear), 25)]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationController?.hidesBarsOnTap = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuLabels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        let label = menuLabels[indexPath.row].0
        let icon = menuLabels[indexPath.row].1
        let iconSize = CGFloat(menuLabels[indexPath.row].2)
        cell.menuLabel.text = label
        cell.menuIcon.setIcon(icon: icon, iconSize: iconSize, color: systemColor, bgColor: .clear)
        return cell
    }
    
    
}
