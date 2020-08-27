//
//  PlaylistCell.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/26/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var selectIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectIcon.setIcon(icon: .ionicons(.iosArrowForward),
                           iconSize: 28,
                           color: .systemColor,
                           backgroundColor: .white,
                           forState: .normal)
    }
}
