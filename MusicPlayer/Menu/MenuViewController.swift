//
//  MenuViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 4/24/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import GCDWebServer
class MenuViewController: UIViewController {
    
    var webUploader: GCDWebUploader? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var serverAddress: UILabel!
    @IBAction func serverSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let documentsPath: String? = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            webUploader = GCDWebUploader(uploadDirectory: documentsPath)
            webUploader!.start()
            serverAddress.text = webUploader?.serverURL.absoluteString
        } else {
            webUploader?.stop()
            serverAddress.text = ""
        }
    }
}
