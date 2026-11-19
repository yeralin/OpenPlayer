//
//  ServerAddress.swift
//  MusicPlayer
//

import Foundation

enum ServerAddress {

    /// Turns what the user typed into the Settings server field into the
    /// address that is stored and requested, or nil when the field is blank.
    ///
    /// An explicit `http://` or `https://` scheme is kept. Anything else gets
    /// `http://`, since self-hosted servers on a LAN rarely have TLS
    /// certificates.
    static func normalize(_ input: String) -> String? {
        let address = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else {
            return nil
        }
        let lowercased = address.lowercased()
        if lowercased.hasPrefix("http://") || lowercased.hasPrefix("https://") {
            return address
        }
        return "http://" + address
    }
}
