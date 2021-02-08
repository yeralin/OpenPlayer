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
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        menuButton.target = self.revealViewController()
        navBar.delegate = self
    }
    
    internal func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    @IBAction func serverSwitch(_ sender: UISwitch) {
        let switchedOn = sender.isOn
        if switchedOn {
            if let address = self.deployServer() {
                serverAddressLabel.text = address.absoluteString
                menuButton.isEnabled = false
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                let alert = popUIErrorAlert(title: "Failed starting the web server",
                                            reason: "Is your Wi-Fi on and \n connected to a network?")
                self.present(alert, animated: true, completion: nil)
                sender.isOn = false
            }
        } else {
            self.stopServer()
            serverAddressLabel.text = "Inactive"
            UIApplication.shared.isIdleTimerDisabled = false
            menuButton.isEnabled = true
        }
    }
    
}
