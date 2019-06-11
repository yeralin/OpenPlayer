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
    var serverAddress: URL?
    
    init() {
        fetchSettings()
    }
    
    internal func fetchSettings() {
        if let serverSettings = UserDefaults.standard.object(forKey: "serverSettings") as? [String : String] {
            if let storedServerAddress = serverSettings["serverAddress"] {
                serverAddress = URL(string: storedServerAddress)
            }
        }
    }
    
    func getVersion(completion: @escaping (String, RequestError?) -> ()) {
        fetchSettings()
        if var requestUrl = serverAddress {
            let versionEndpoint = "/version"
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
        } else {
            return completion("Unknown", RequestError.ConnectionIssue)
        }
    }
    
    func getSongs(query: String,
                  endpoint: String,
                  completion: @escaping ([[String:String]]?, RequestError?) -> ()) {
        fetchSettings()
        if var requestUrl = serverAddress {
            requestUrl.appendPathComponent(endpoint)
            let params = ["q": query]
            Alamofire.request(requestUrl, method: .get, parameters: params)
                .validate()
                .responseJSON { res in
                    switch res.result {
                    case .success(let responseData):
                        if let songListResponse = responseData as? [[String:String]] {
                            return completion(songListResponse, nil)
                        }
                        return completion(nil, RequestError.FailToParse)
                    case .failure:
                        return completion(nil, RequestError.ConnectionIssue)
                    }
                }
        }
    }
    
    
    
}
