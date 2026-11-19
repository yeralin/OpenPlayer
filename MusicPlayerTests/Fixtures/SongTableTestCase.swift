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
        // Dismiss alerts and detach the controller before dropping the window,
        // so the next test starts without a half-finished presentation.
        window?.rootViewController?.dismiss(animated: false)
        window?.rootViewController = nil
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

    /// Puts the controller in a visible window and waits until it has
    /// appeared, so it can present alerts. UIKit drops a presentation that
    /// starts while the presenter is still being added to the window.
    func show(_ controller: UIViewController) throws {
        let scene = try XCTUnwrap(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
            "The host app has no window scene")
        let window = UIWindow(windowScene: scene)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window

        let inWindow = expectation(for: NSPredicate { _, _ in controller.viewIfLoaded?.window != nil },
                                   evaluatedWith: nil)
        wait(for: [inWindow], timeout: 2)
        // viewDidAppear runs on a later run loop pass than the window change.
        let appeared = expectation(description: "appearance transition finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { appeared.fulfill() }
        wait(for: [appeared], timeout: 2)
    }

    func cell(_ table: SongTableViewController, row: Int) -> SongCell? {
        table.tableView(table.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? SongCell
    }
}
