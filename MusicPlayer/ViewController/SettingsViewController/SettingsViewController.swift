//
//  SettingsViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/11/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftOverlays
import SWRevealViewController

class SettingsViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var memoryLabel: UILabel!
    
    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var serverStatusLabel: UILabel!
    @IBOutlet weak var serverVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuGestureRecognizer()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        menuButton.target = self.revealViewController()
        navBar.delegate = self
        memoryLabel.text = self.reportUsedFreeMem()
        if let serverAddress = SettingsViewController.extractServerSettings()?["serverAddress"] {
            serverAddressField.text = serverAddress
            self.tryConnectToRemoteServer(showProgress: false)
        }
    }
    
    internal func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    internal func textFieldShouldClear(_ textField: UITextField) -> Bool {
        serverAddressField.resignFirstResponder()
        return true
    }
    
    @IBAction func tryConnect(_ sender: UIButton) {
        if serverAddressField.text != "" {
            self.tryConnectToRemoteServer(showProgress: true)
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var serverAddress = serverAddressField.text, serverAddressField.text != "" {
            // TODO: Force user to define the protocol
            if !serverAddress.contains("http") {
                serverAddress = "http://" + serverAddress
                serverAddressField.text = serverAddress
            }
            self.handleServerAddressUpdate(serverAddress)
        }
        textField.resignFirstResponder()
        return true
    }
    
    internal func presentServerConnectionFailureAlert(_ errorMessage: String) {
        let alert = UIAlertController(title: "Error",
                                      message: errorMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
