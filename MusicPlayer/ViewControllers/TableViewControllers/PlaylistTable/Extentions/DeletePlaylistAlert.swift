//
//  DeletePlaylistAlert.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 5/15/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import UIKit

private typealias DeletePlaylistAlert = PlaylistTableViewController
extension DeletePlaylistAlert {
    
    func createDeletePlaylistAlert(onComplete: @escaping (UIAlertAction) -> ()) -> UIAlertController {
        let alertDeleteConfirmation =
            UIAlertController(title: "Warning",
                              message: "Are you sure you want to delete this playlist with all songs in it?!",preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: onComplete)
        alertDeleteConfirmation.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertDeleteConfirmation.addAction(deleteAction)
        return alertDeleteConfirmation
    }
}
