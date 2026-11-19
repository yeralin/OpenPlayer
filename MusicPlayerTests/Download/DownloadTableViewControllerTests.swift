//
//  DownloadTableViewControllerTests.swift
//  MusicPlayerTests
//

import UIKit
import XCTest
@testable import MusicPlayer

final class DownloadTableViewControllerTests: PersistenceTestCase {

    private var originalPlayerDelegate: AudioPlayerDelegate?

    override func setUpWithError() throws {
        try super.setUpWithError()
        originalPlayerDelegate = AudioPlayer.instance.delegate
    }

    override func tearDownWithError() throws {
        AudioPlayer.instance.delegate = originalPlayerDelegate
        try super.tearDownWithError()
    }

    /// The download table as the storyboard builds it, outside the side menu.
    func makeDownloadTable() throws -> DownloadTableViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: DownloadTableViewController.self))
        let controller = try XCTUnwrap(
            storyboard.instantiateViewController(withIdentifier: "downloadTable") as? DownloadTableViewController)
        // Used to crash: viewDidLoad force-unwrapped revealViewController().
        controller.loadViewIfNeeded()
        return controller
    }

    func testLoadsOutsideTheSideMenu() throws {
        let controller = try makeDownloadTable()

        XCTAssertNil(controller.revealViewController())
        XCTAssertEqual(controller.tableView(controller.tableView, numberOfRowsInSection: 0), 0)
    }

    func testShowsOneRowPerSearchResult() throws {
        let controller = try makeDownloadTable()
        controller.populateSongListResponse([
            SearchResultEntry(source: "test", title: "Artist - Title", url: URL(string: "http://127.0.0.1:9/1.mp3")!),
        ])

        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        let downloadCell = try XCTUnwrap(cell as? DownloadCell)
        XCTAssertEqual(downloadCell.artistName.text, "Artist")
        XCTAssertEqual(downloadCell.songTitle.text, "Title")
    }
}
