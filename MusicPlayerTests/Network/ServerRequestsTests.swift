//
//  ServerRequestsTests.swift
//  MusicPlayerTests
//

import Alamofire
import XCTest
@testable import MusicPlayer

final class ServerRequestsTests: XCTestCase {

    private let server = URL(string: "http://music.example:8080")!

    /// Requests are only built, never sent: the session does not start them.
    private func makeRequests(credentials: ServerCredentials?) -> ServerRequests {
        let session = Session(configuration: .ephemeral, startRequestsImmediately: false)
        return ServerRequests(session: session, credentials: credentials)
    }

    func testSearchAuthenticatesWithConfiguredCredentials() {
        let credentials = ServerCredentials(infoDictionary: [
            ServerCredentials.usernameKey: "alice",
            ServerCredentials.passwordKey: "s3cret",
        ])
        XCTAssertNotNil(credentials)

        let request = makeRequests(credentials: credentials)
            .searchRequest(serverAddress: server, query: "song")

        XCTAssertEqual(request.credential?.user, "alice")
        XCTAssertEqual(request.credential?.password, "s3cret")
    }

    func testSearchSendsNoCredentialsWhenNoneAreConfigured() {
        let request = makeRequests(credentials: nil)
            .searchRequest(serverAddress: server, query: "song")

        XCTAssertNil(request.credential)
    }

    func testSearchTargetsTheSearchEndpointWithTheQuery() throws {
        let request = makeRequests(credentials: nil)
            .searchRequest(serverAddress: server, query: "daft punk")

        let url = try XCTUnwrap(try request.convertible.asURLRequest().url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.host, "music.example")
        XCTAssertEqual(components.port, 8080)
        XCTAssertEqual(components.path, "/search")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "q", value: "daft punk")])
    }
}
