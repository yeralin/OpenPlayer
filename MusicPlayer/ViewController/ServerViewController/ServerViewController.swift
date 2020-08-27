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
    
    internal func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    internal func presentErrorAlert() {
        let alert = UIAlertController(title: "Failure",
                                      message: "Is your Wi-Fi on and \n connected to a network?",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Let me fix this!",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func serverSwitch(_ sender: UISwitch) {
        let switchedOn = sender.isOn
        if switchedOn {
            if let address = self.deployServer() {
                serverAddressLabel.text = address.absoluteString
                menuButton.disableButton()
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                presentErrorAlert()
                sender.isOn = false
            }
        } else {
            self.stopServer()
            serverAddressLabel.text = "Inactive"
            UIApplication.shared.isIdleTimerDisabled = false
            menuButton.enableButton()
        }
    }
    
}
