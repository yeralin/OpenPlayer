//
//  PlaylistCellView.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIconFont
import CoreData

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var selectIcon: UIButton!
    private final var arrowIcon: String = "angle.right"

    override func awakeFromNib() {
        super.awakeFromNib()
        selectIcon.setIconWithSize(icon: arrowIcon, font: .Themify, size: 20)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
