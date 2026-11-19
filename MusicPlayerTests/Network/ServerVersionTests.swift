//
//  ServerVersionTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class ServerVersionTests: XCTestCase {

    private func fetchVersion(statusCode: Int = 200, body: String) -> (String, Response) {
        let session = StubURLProtocol.session(answering: .init(statusCode: statusCode, body: Data(body.utf8)))
        let requests = ServerRequests(session: session, credentials: nil)
        let done = expectation(description: "getVersion")
        var result: (String, Response) = ("", .Successful)
        requests.getVersion(serverAddress: URL(string: "http://music.example")!) { version, response in
            result = (version, response)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        return result
    }

    func testReadsTheVersion() {
        let (version, response) = fetchVersion(body: #"{"version": "1.2.3"}"#)

        XCTAssertEqual(version, "1.2.3")
        XCTAssertEqual(response, .Successful)
    }

    func testExtraFieldsAreIgnored() {
        // The old [String: String] cast failed on any non-string field.
        let (version, response) = fetchVersion(body: #"{"version": "1.2.3", "build": 42}"#)

        XCTAssertEqual(version, "1.2.3")
        XCTAssertEqual(response, .Successful)
    }

    func testBodyWithoutAVersionFailsToParse() {
        XCTAssertEqual(fetchVersion(body: #"{"name": "OpenPlayer"}"#).1, .FailedToParse)
        XCTAssertEqual(fetchVersion(body: "not json").1, .FailedToParse)
    }

    func testHttpErrorIsAConnectionIssue() {
        let (version, response) = fetchVersion(statusCode: 500, body: "")

        XCTAssertEqual(version, "Unknown")
        XCTAssertEqual(response, .ConnectionIssue)
    }
}
