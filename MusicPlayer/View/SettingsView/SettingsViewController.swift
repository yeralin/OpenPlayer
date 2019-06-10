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
        menuButton.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: .systemColor,
                           cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                           target: self.revealViewController(),
                           action: #selector(SWRevealViewController.revealToggle(_:)))
        navBar.delegate = self
        memoryLabel.text = self.reportUsedFreeMem()
        if let serverAddress = self.extractServerSettings()?["serverAddress"] {
            serverAddressField.text = serverAddress
            self.tryConnectToRemoteServer(showErrorAlert: false)
        }
    }
    
    @IBAction func tryConnect(_ sender: UIButton) {
        if serverAddressField.text != "" {
            self.tryConnectToRemoteServer(showErrorAlert: true)
        }
    }
    
    internal func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    internal func textFieldShouldClear(_ textField: UITextField) -> Bool {
        serverAddressField.resignFirstResponder()
        return true
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
    
    internal func handleServerResponse(version: String, _ requestError: RequestError?, _ showErrorAlert: Bool) {
        if let error = requestError {
            var errorMessage = "Error: Unknown error has occured"
            switch error {
            case RequestError.ConnectionIssue:
                errorMessage = "Error: Could not connect to a remote server"
            case RequestError.FailToParse:
                errorMessage = "Error: Could not parse server response"
            }
            DispatchQueue.main.async {
                self.serverVersionLabel.text = "Unknown"
                self.serverStatusLabel.text = "Not connected"
                self.serverStatusLabel.textColor = UIColor.red
                if showErrorAlert == true {
                    self.presentServerConnectionFailureAlert(errorMessage)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.serverVersionLabel.text = version
                self.serverStatusLabel.text = "Connected"
                self.serverStatusLabel.textColor = UIColor.green
            }
        }
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
