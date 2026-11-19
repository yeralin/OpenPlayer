//
//  UITestLaunchArguments.swift
//  MusicPlayer
//
//  Launch arguments the UI tests pass to start the app in a known state.
//

import Foundation

struct UITestLaunchArguments: Equatable {

    /// Delete every playlist (folders and Core Data rows) before the UI loads.
    static let resetStateFlag = "--reset-state"

    struct PlaylistSeed: Equatable {
        var name: String
        var songCount: Int
    }

    var resetState = false
    /// From `<playlistName>:<numberOfTestSongs>` arguments: playlists to create,
    /// each filled with copies of the bundled test song.
    var playlists: [PlaylistSeed] = []

    /// `arguments` excludes the executable path. Anything that is neither the
    /// reset flag nor `name:count` is ignored: the system adds its own
    /// arguments, such as `-AppleLanguages (en)`.
    init(_ arguments: [String]) {
        for argument in arguments {
            if argument == Self.resetStateFlag {
                resetState = true
                continue
            }
            let parts = argument.split(separator: ":", maxSplits: 1)
            guard parts.count == 2, !parts[0].hasPrefix("-"),
                  let count = Int(parts[1]), count >= 0 else {
                continue
            }
            playlists.append(PlaylistSeed(name: String(parts[0]), songCount: count))
        }
    }

    static var current: UITestLaunchArguments {
        UITestLaunchArguments(Array(ProcessInfo.processInfo.arguments.dropFirst()))
    }
}
