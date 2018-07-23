//
//  CloseMenuOnTap.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/12/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SWRevealViewController

extension UIBarButtonItem {
    
    func disableButton() {
        self.isEnabled = false
        (self.customView as! UIButton).setTitleColor(.gray, for: .normal)
    }
    
    func enableButton() {
        self.isEnabled = true
        (self.customView as! UIButton).setTitleColor(.systemColor, for: .normal)
    }
}


extension UIViewController: SWRevealViewControllerDelegate {
    
    func setupMenuButton(button: UIBarButtonItem) {
        button.setIcon(icon: .ionicons(.navicon),  iconSize: 35, color: .systemColor,
                           cgRect: CGRect(x: 0, y: 0, width: 30, height: 30),
                           target: self.revealViewController(),
                           action: #selector(SWRevealViewController.revealToggle(_:)))
    }
    
    func setupMenuGestureRecognizer() {
        revealViewController().delegate = self
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
}
