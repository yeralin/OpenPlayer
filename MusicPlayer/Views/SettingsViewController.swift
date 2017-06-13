//
//  SettingsViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/11/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SWRevealViewController

class SettingsViewController: UIViewController, UINavigationBarDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var memoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButton.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: .systemColor,
                           cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                           target: self.revealViewController(),
                           action: #selector(SWRevealViewController.revealToggle(_:)))
        navBar.delegate = self
        memoryLabel.text = reportUsedFreeMem()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func reportUsedFreeMem() -> String {
        let used: String = {
            var usedSpace = "Unknown"
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var bool: ObjCBool = false
            if FileManager.default.fileExists(atPath: documentsDirectoryURL.path, isDirectory: &bool), bool.boolValue {
                var folderSize = 0
                FileManager.default.enumerator(at: documentsDirectoryURL, includingPropertiesForKeys: [.fileSizeKey], options: [])?.forEach {
                    folderSize += (try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey]))??.fileSize ?? 0
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
    
}
