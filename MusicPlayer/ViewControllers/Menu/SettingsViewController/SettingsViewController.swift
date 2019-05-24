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
    
    @IBAction func tryConnect(_ sender: UIButton) {
        if serverAddressField.text != "" {
            tryConnectToServer(showErrorAlert: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuGestureRecognizer()
        menuButton.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: .systemColor,
                           cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                           target: self.revealViewController(),
                           action: #selector(SWRevealViewController.revealToggle(_:)))
        navBar.delegate = self
        memoryLabel.text = reportUsedFreeMem()
        if let serverSettings = UserDefaults.standard.object(forKey: "serverSettings") as? [String : String] {
            if let serverAddress = serverSettings["serverAddress"] {
                serverAddressField.text = serverAddress
                tryConnectToServer(showErrorAlert: false)
            }
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        serverAddressField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var serverAddress = serverAddressField.text, serverAddressField.text != "" {
            if !serverAddress.contains("http") {
                serverAddress = "http://" + serverAddress
            }
            var serverSettings: [String:String]
            if let dict = UserDefaults.standard.object(forKey: "serverSettings") as? [String : String] {
                serverSettings = dict
                serverSettings["serverAddress"] = serverAddress
            } else {
                serverSettings = ["serverAddress": serverAddress]
            }
            UserDefaults.standard.set(serverSettings, forKey: "serverSettings")
            tryConnectToServer(showErrorAlert: true)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func reportUsedFreeMem() -> String {
        let used: String = {
            var usedSpace = "Unknown"
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var bool: ObjCBool = false
            if FileManager.default.fileExists(atPath: documentsDirectoryURL.path, isDirectory: &bool), bool.boolValue {
                var folderSize = 0
                FileManager.default.enumerator(at: documentsDirectoryURL, includingPropertiesForKeys: [.fileSizeKey], options: [])?.forEach {
                    folderSize += (((try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey])) as URLResourceValues??))??.fileSize ?? 0
                }
                usedSpace = ByteCountFormatter.string(fromByteCount: Int64(folderSize), countStyle: .file)
            }
            return usedSpace
        }()
        let free: String = {
            var remainingSpace = "Unknown"
            if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
                let freeSpaceSize = attributes[FileAttributeKey.systemFreeSize] as? Int64 {
                remainingSpace = ByteCountFormatter.string(fromByteCount: freeSpaceSize, countStyle: .file)
            }
            return remainingSpace
        }()
        return used + " / " + free
    }
    
    func tryConnectToServer(showErrorAlert: Bool) {
        if showErrorAlert == true {
            let text = "Trying to connect..."
            self.showTextOverlay(text)
        }
        ServerRequests.sharedInstance.getVersion(completion: {
            version, requestError in
            self.removeAllOverlays()
            if let error = requestError {
                var errorText = ""
                switch error {
                case RequestError.ConnectionIssue:
                    errorText = "Error: Could not connect to a server"
                case RequestError.FailToParse:
                    errorText = "Error: Could not parse server response"
                }
                DispatchQueue.main.async {
                    self.serverVersionLabel.text = "Unknown"
                    self.serverStatusLabel.text = "Not connected"
                    self.serverStatusLabel.textColor = UIColor.red
                    if showErrorAlert == true {
                        let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.serverVersionLabel.text = version
                    self.serverStatusLabel.text = "Connected"
                    self.serverStatusLabel.textColor = UIColor.green
                    self.removeAllOverlays()
                }
            }
        })
        
    }
}
