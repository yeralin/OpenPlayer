//
//  MenuTableViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/29/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import GCDWebServer

class MenuTableViewController: UITableViewController {
    
    let menuEntries = ["Playlists", "Download", "Search", "Server", "Settings"]
    var webUploader: GCDWebUploader? = nil
    
    @IBOutlet weak var address: UILabel!
    
    @IBAction func serverSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let documentsPath: String? = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            webUploader = GCDWebUploader(uploadDirectory: documentsPath)
            webUploader!.start()
            address.text = webUploader?.serverURL.absoluteString
        } else {
            webUploader?.stop()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuEntries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "menuCell")
        cell.textLabel?.text = menuEntries[indexPath.row]
        // Configure the cell...
        
        return cell
    }
    
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
