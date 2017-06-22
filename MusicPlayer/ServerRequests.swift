//
//  ServerRequests.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/16/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import Alamofire

enum RequestError: Error {
    case FailToParse
    case ConnectionIssue
}

class ServerRequests {
    
    static let sharedInstance = ServerRequests()
    
    func getVersion(serverAddress: String, completion: @escaping (String, RequestError?) -> ()) {
        let versionEndpoint = "/version"
        guard var requestUrl = URL(string:serverAddress) else { return }
        requestUrl.appendPathComponent(versionEndpoint)
        Alamofire.request(requestUrl, method: .get)
            .validate()
            .responseJSON { res in
                switch res.result {
                case .success(let responseData):
                    if let version = (responseData as? [String:String])?["version"] {
                        return completion(version, nil)
                    }
                    return completion("Unknown", RequestError.FailToParse)
                case .failure:
                    return completion("Unknown", RequestError.ConnectionIssue)
                }
        }
    }
    
    
    
}
