//
//  Extentions.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import SwiftIconFont

public extension UIButton {
    func setIconWithSize(icon: String, font: Fonts, size: CGFloat) {
        switch font {
        case .FontAwesome:
            self.setTitle(String.fontAwesomeIcon(icon), for: .normal)
        case .Iconic:
            self.setTitle(String.fontIconicIcon(icon), for: .normal)
        case .Ionicon:
            self.setTitle(String.fontIonIcon(icon), for: .normal)
        case .MapIcon:
            self.setTitle(String.fontMapIcon(icon), for: .normal)
        case .MaterialIcon:
            self.setTitle(String.fontMaterialIcon(icon), for: .normal)
        case .Octicon:
            self.setTitle(String.fontOcticon(icon), for: .normal)
        case .Themify:
            self.setTitle(String.fontThemifyIcon(icon), for: .normal)
        }
        self.titleLabel?.font = UIFont.icon(from: font, ofSize: size)
    }
}

public extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
