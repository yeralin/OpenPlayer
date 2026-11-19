//
//  MenuTableViewController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/29/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

import SWRevealViewController

extension UIViewController: SWRevealViewControllerDelegate {
    
    func setupMenuGestureRecognizer() {
        // nil when the screen is shown outside the side menu (e.g. in tests).
        guard let revealController = revealViewController() else {
            return
        }
        revealController.delegate = self
        view.addGestureRecognizer(revealController.tapGestureRecognizer())
    }
}

class MenuCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
}

class MenuTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationController?.hidesBarsOnTap = false
    }

}
