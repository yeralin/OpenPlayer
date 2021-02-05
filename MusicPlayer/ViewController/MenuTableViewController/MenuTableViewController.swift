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
        revealViewController().delegate = self
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
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
