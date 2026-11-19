//
//  SearchErrorMessageTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class SearchErrorMessageTests: XCTestCase {

    private func message(_ status: Response) -> String {
        DownloadTableViewController.searchErrorMessage(for: status)
    }

    func testUndecodableResponseIsReportedAsAParseError() {
        // The request succeeded but its body could not be decoded. This used
        // to show "Unknown error occurred": the intended FailedToParse status
        // was written to a local variable that nothing read.
        XCTAssertEqual(message(.Successful), "Error: Could not parse server response")
        XCTAssertEqual(message(.FailedToParse), "Error: Could not parse server response")
    }

    func testOtherStatuses() {
        XCTAssertEqual(message(.ConnectionIssue), "Error: Could not connect to the server")
        XCTAssertEqual(message(.ServerUndefined), "Error: No server URL was defined in settings")
    }
}
