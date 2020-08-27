//
//  MenuTableViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/29/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIcons

import SWRevealViewController

extension UIViewController: SWRevealViewControllerDelegate {
    
    func setupMenuButton(button: UIBarButtonItem) {
        button.setIcon(icon: .ionicons(.navicon),
                iconSize: 35,
                color: .systemColor,
                cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                target: self.revealViewController(),
                action: #selector(SWRevealViewController.revealToggle(_:)))
    }
    
    func setupMenuGestureRecognizer() {
        revealViewController().delegate = self
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
}

class MenuCell: UITableViewCell {
    @IBOutlet weak var menuIcon: UILabel!
    @IBOutlet weak var menuLabel: UILabel!

    // TODO: Remove dependency on labels
    override func awakeFromNib() {
        super.awakeFromNib()
        if let menuEntryText = menuLabel.text {
            switch menuLabel.text {
            case "Playlists":
                menuIcon.setIcon(icon: FontType.ionicons(.iosMusicalNotes),
                        iconSize: 28, color: .systemColor, bgColor: .clear)
            case "Download":
                menuIcon.setIcon(icon: FontType.ionicons(.iosSearchStrong),
                        iconSize: 25, color: .systemColor, bgColor: .clear)
            case "Web Server":
                menuIcon.setIcon(icon: FontType.ionicons(.iosCloud),
                        iconSize: 25, color: .systemColor, bgColor: .clear)
            case "Settings":
                menuIcon.setIcon(icon: FontType.ionicons(.iosGear),
                        iconSize: 25, color: .systemColor, bgColor: .clear)
            default:
                fatalError("Failed to construct menu table: unrecognized menu entry \(menuEntryText)")
            }
        }
    }
}

class MenuTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationController?.hidesBarsOnTap = false
    }

}
