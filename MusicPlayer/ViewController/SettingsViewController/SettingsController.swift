//
//  SettingsController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/9/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import UIKit

// MARK: SettingsView controller
extension SettingsViewController {
    
    static func extractServerSettings() -> [String : String]? {
        if let serverSettings = UserDefaults.standard.object(forKey: "serverSettings") as? [String : String] {
            return serverSettings
        }
        return nil
    }
    
    internal func reportUsedFreeMem() -> String {
        let used: String = calculateUsedSpace()
        let free: String = calculateFreeSpace()
        return used + " / " + free
    }
    
    internal func handleServerAddressUpdate(_ serverAddress: String) {
        var serverSettings = SettingsViewController.extractServerSettings() ?? [:]
        serverSettings["serverAddress"] = serverAddress
        UserDefaults.standard.set(serverSettings, forKey: "serverSettings")
        tryConnectToRemoteServer(showProgress: true)
    }
    
    internal func calculateUsedSpace() -> String {
        var usedSpace = "Unknown"
        var bool: ObjCBool = false
        guard let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory,
                                                                    in: .userDomainMask).first else {
            log.error("Could not retrieve document dir")
            return usedSpace
        }
        if FileManager.default.fileExists(atPath: documentsDirectoryURL.path, isDirectory: &bool), bool.boolValue {
            var dirSize = 0
            FileManager.default.enumerator(at: documentsDirectoryURL,
                                           includingPropertiesForKeys: [.fileSizeKey],
                                           options: [])?.forEach {
                // Using black magic to get a directory file size
                dirSize += (((try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey])) as URLResourceValues??))??.fileSize ?? 0
            }
            usedSpace = ByteCountFormatter.string(fromByteCount: Int64(dirSize), countStyle: .file)
        }
        return usedSpace
    }
    
    internal func calculateFreeSpace() -> String {
        var remainingSpace = "Unknown"
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
            let freeSpaceSize = attributes[FileAttributeKey.systemFreeSize] as? Int64 {
            remainingSpace = ByteCountFormatter.string(fromByteCount: freeSpaceSize, countStyle: .file)
        }
        return remainingSpace
    }
    
    internal func tryConnectToRemoteServer(showProgress: Bool) {
        if showProgress == true {
            let text = "Trying to connect..."
            self.showTextOverlay(text)
        }
        ServerRequests.sharedInstance.getVersion(completion: { version, response in
            self.removeAllOverlays()
            if response == .Successful {
                DispatchQueue.main.async {
                    self.serverVersionLabel.text = version
                    self.serverStatusLabel.text = "Connected"
                    self.serverStatusLabel.textColor = UIColor.green
                }
            } else {
                var errorMessage: String?
                switch response {
                case .ConnectionIssue:
                    errorMessage = "Error: Could not connect to a remote server"
                case .FailedToParse:
                    errorMessage = "Error: Could not parse server response"
                case .ServerUndefined:
                    errorMessage = "Error: No server URL was defined in settings"
                default:
                    errorMessage = "Error: Unknown error occurred"
                }
                DispatchQueue.main.async {
                    self.serverVersionLabel.text = "Unknown"
                    self.serverStatusLabel.text = "Not connected"
                    self.serverStatusLabel.textColor = UIColor.red
                    if let errorMessage = errorMessage,
                       showProgress == true {
                        self.presentServerConnectionFailureAlert(errorMessage)
                    }
                }
            }
        })
    }
    
}
