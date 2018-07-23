//
//  CloseMenuOnTap.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/12/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SWRevealViewController


extension UIViewController: SWRevealViewControllerDelegate {
    
    func setupMenuGestureRecognizer() {
        revealViewController().delegate = self
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
    
    public func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if revealController.frontViewPosition == FrontViewPosition.left {
            if let tableViewController = self as? UITableViewController {
                tableViewController.tableView.alwaysBounceVertical = true
                tableViewController.tableView.allowsSelection = true
            }
        } else if revealController.frontViewPosition == FrontViewPosition.right {
            if let tableViewController = self as? UITableViewController {
                tableViewController.tableView.alwaysBounceVertical = false
                tableViewController.tableView.allowsSelection = false
            }
        }
        
    }
}
