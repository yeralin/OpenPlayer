//
//  SongTableTestCase.swift
//  MusicPlayerTests
//

import UIKit
import XCTest
@testable import MusicPlayer

/// Base class for tests that drive `SongTableViewController` from
/// Main.storyboard against the temporary persistence from `PersistenceTestCase`.
///
/// The controller makes itself `AudioPlayer.instance.delegate` when it is
/// created, so the shared player's delegate is restored, and the shared player
/// stopped, after each test.
class SongTableTestCase: PersistenceTestCase {

    private var originalPlayerDelegate: AudioPlayerDelegate?
    private var window: UIWindow?

    override func setUpWithError() throws {
        try super.setUpWithError()
        originalPlayerDelegate = AudioPlayer.instance.delegate
    }

    override func tearDownWithError() throws {
        try? AudioPlayer.instance.stop() // Nothing may be playing.
        AudioPlayer.instance.delegate = originalPlayerDelegate
        window?.isHidden = true
        window = nil
        try super.tearDownWithError()
    }

    /// A loaded song table showing `playlist`.
    func makeSongTable(for playlist: PlaylistEntity) throws -> SongTableViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: SongTableViewController.self))
        let controller = try XCTUnwrap(
            storyboard.instantiateViewController(withIdentifier: "songTable") as? SongTableViewController)
        controller.prepareSongs(targetPlaylist: playlist)
        controller.loadViewIfNeeded()
        return controller
    }

    /// Puts the controller in a visible window, so it can present alerts.
    func show(_ controller: UIViewController) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
    }

    func cell(_ table: SongTableViewController, row: Int) -> SongCell? {
        table.tableView(table.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? SongCell
    }
}
