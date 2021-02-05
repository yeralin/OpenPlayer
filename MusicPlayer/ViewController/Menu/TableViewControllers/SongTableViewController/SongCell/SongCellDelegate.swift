//
//  CustomSongCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/9/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

protocol CellToTableDelegate: class {
    func presentAlertForCell(alert: UIAlertController, alertName: String)
    func performSegueForCell(sender: Any?, identifier: String)
    func propagateError(title: String, error: String)
}

