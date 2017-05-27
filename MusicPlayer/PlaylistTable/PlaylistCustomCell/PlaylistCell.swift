//
//  PlaylistCellView.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/8/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit
import SwiftIcons
import CoreData

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var selectIcon: UIButton!
    private final var arrowIcon: String = "angle.right"

    override func awakeFromNib() {
        super.awakeFromNib()
        selectIcon.setIcon(icon: .fontAwesome(.angleRight), iconSize: 28, color: systemColor, forState: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
