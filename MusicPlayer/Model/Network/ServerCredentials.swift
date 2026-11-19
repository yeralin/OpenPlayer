//
//  ServerCredentials.swift
//  MusicPlayer
//
//  Username and password for OpenPlayer-Server, read from the build's
//  Info.plist (see Config/Secrets.example.xcconfig).
//

import Foundation

struct ServerCredentials: Equatable {

    static let usernameKey = "OPServerUsername"
    static let passwordKey = "OPServerPassword"

    let username: String
    let password: String

    /// Credentials baked into this build, or nil when none were configured.
    static var bundled: ServerCredentials? {
        ServerCredentials(infoDictionary: Bundle.main.infoDictionary)
    }

    /// Returns nil unless both the username and the password are non-empty,
    /// so a build without Config/Secrets.xcconfig talks to the server
    /// without authentication.
    init?(infoDictionary: [String: Any]?) {
        guard let username = infoDictionary?[Self.usernameKey] as? String,
              let password = infoDictionary?[Self.passwordKey] as? String,
              !username.isEmpty, !password.isEmpty else {
            return nil
        }
        self.username = username
        self.password = password
    }
}
