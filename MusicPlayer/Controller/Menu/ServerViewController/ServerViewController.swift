//
//  ServerViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/6/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import GCDWebServer
import SWRevealViewController

class ServerViewController: UIViewController, UINavigationBarDelegate {
    var webUploader: GCDWebUploader? = nil
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var serverAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuGestureRecognizer()
        setupMenuButton(button: menuButton)
        navBar.delegate = self
    }
    
    @IBAction func serverSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let docsUrl = PlaylistPersistencyManager.sharedInstance.docsUrl.path
            webUploader = GCDWebUploader(uploadDirectory: docsUrl)
            //let backgroundOption = [GCDWebServerOption_AutomaticallySuspendInBackground: false]
            webUploader!.start(withPort: 80, bonjourName: nil)
            if let address = webUploader?.serverURL {
                AudioPlayer.sharedInstance.stopSong()
                serverAddressLabel.text = address.absoluteString
                menuButton.disableButton()
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                let alert = UIAlertController(title: "Failure", message: "Is your Wi-Fi on and \n connected to a network?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Let me fix this!", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                sender.isOn = false
            }
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
            webUploader?.stop()
            serverAddressLabel.text = "Inactive"
            menuButton.enableButton()
        }
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}
