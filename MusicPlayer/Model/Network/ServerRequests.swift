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

    private let session: Session
    private let credentials: ServerCredentials?

    /// - Parameter credentials: sent to `/search` when present. Defaults to
    ///   the build's credentials (see Config/Secrets.example.xcconfig).
    init(session: Session = AF, credentials: ServerCredentials? = .bundled) {
        self.session = session
        self.credentials = credentials
    }
    
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
        session.request(versionEndpoint, method: .get)
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
        searchRequest(serverAddress: serverAddress, query: query)
            .responseData { res in
                switch res.result {
                case .success(let responseData):
                    return completion(responseData, Response.Successful)
                case .failure:
                    return completion(nil, Response.ConnectionIssue)
                }
            }
    }

    /// The `/search` request, authenticated only when credentials are set.
    internal func searchRequest(serverAddress: URL, query: String) -> DataRequest {
        let endpoint = serverAddress.appendingPathComponent("/search")
        let request = session.request(endpoint, method: .get, parameters: ["q": query])
        if let credentials = credentials {
            request.authenticate(username: credentials.username, password: credentials.password)
        }
        return request.validate()
    }
}
