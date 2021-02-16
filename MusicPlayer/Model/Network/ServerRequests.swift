//
//  ServerRequests.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/16/17.
//  Copyright © 2017 Daniyar Yeralin. All rights reserved.
//

import Foundation
import Alamofire

enum Response: Error {
    case Successful
    case FailedToParse
    case ConnectionIssue
    case ServerUndefined
}

class ServerRequests {
    
    static let sharedInstance = ServerRequests()
    
    internal func fetchServerURL() -> URL? {
        if let serverSettings = SettingsViewController.extractServerSettings(),
           let storedServerAddress = serverSettings["serverAddress"],
           let serverAddress = URL(string: storedServerAddress) {
            return serverAddress
        }
        return nil
    }

    func getVersion(completion: @escaping (String, Response) -> ()) {
        guard let serverAddress = fetchServerURL() else {
            return completion("Unknown", .ServerUndefined)
        }
        let versionEndpoint = serverAddress.appendingPathComponent("/version")
        AF.request(versionEndpoint, method: .get)
            .validate()
            .responseJSON { res in
                switch res.result {
                case .success(let responseData):
                    if let version = (responseData as? [String:String])?["version"] {
                        return completion(version, .Successful)
                    }
                    return completion("Unknown", .FailedToParse)
                case .failure:
                    return completion("Unknown", .ConnectionIssue)
                }
        }
    }
    
    func getSongs(query: String, completion: @escaping (Data?, Response) -> ()) {
        guard let serverAddress = fetchServerURL() else {
            return completion(nil, .ServerUndefined)
        }
        let getSongsEndpoint = serverAddress.appendingPathComponent("/search")
        let params = ["q": query]
        AF.request(getSongsEndpoint, method: .get, parameters: params)
            .authenticate(username: "daniyar", password: "dj2gvcP6%oN%eq")
            .validate()
            .responseData { res in
                switch res.result {
                case .success(let responseData):
                    return completion(responseData, Response.Successful)
                case .failure:
                    return completion(nil, Response.ConnectionIssue)
                }
            }
    }
}
