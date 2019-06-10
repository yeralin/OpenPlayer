//
//  SettingsController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/9/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias SettingsController = SettingsViewController
extension SettingsController {
    
    internal func extractServerSettings() -> [String : String]? {
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
        var serverSettings: [String:String] = [:]
        if let extractedServerSettings = self.extractServerSettings() {
            serverSettings = extractedServerSettings
        }
        serverSettings["serverAddress"] = serverAddress
        UserDefaults.standard.set(serverSettings, forKey: "serverSettings")
        tryConnectToRemoteServer(showErrorAlert: true)
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
    
    internal func tryConnectToRemoteServer(showErrorAlert: Bool) {
        if showErrorAlert == true {
            let text = "Trying to connect..."
            self.showTextOverlay(text)
        }
        ServerRequests.sharedInstance.getVersion(completion: {
            version, requestError in
            self.removeAllOverlays()
            self.handleServerResponse(version: version, requestError, showErrorAlert)
        })
        
    }
}
