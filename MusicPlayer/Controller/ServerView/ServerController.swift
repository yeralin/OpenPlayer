//
//  ServerController.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/9/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation
import GCDWebServer

private typealias ServerController = ServerViewController
extension ServerController {
    
    internal func deployServer() -> URL? {
        let docsUrl = PlaylistPersistencyManager.sharedInstance.docsUrl.path
        webUploader = GCDWebUploader(uploadDirectory: docsUrl)
        // TODO: Enable feature to keep the server up after the application is closed
        //let backgroundOption = [GCDWebServerOption_AutomaticallySuspendInBackground: false]
        webUploader!.start(withPort: 80, bonjourName: nil)
        return webUploader?.serverURL
    }
    
    internal func stopServer() {
        webUploader?.stop()
    }
}
