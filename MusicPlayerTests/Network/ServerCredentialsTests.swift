//
//  ServerCredentialsTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class ServerCredentialsTests: XCTestCase {

    private func credentials(username: Any?, password: Any?) -> ServerCredentials? {
        var info: [String: Any] = [:]
        info[ServerCredentials.usernameKey] = username
        info[ServerCredentials.passwordKey] = password
        return ServerCredentials(infoDictionary: info)
    }

    func testReadsUsernameAndPassword() {
        let result = credentials(username: "alice", password: "s3cret")

        XCTAssertEqual(result?.username, "alice")
        XCTAssertEqual(result?.password, "s3cret")
    }

    func testNoCredentialsWhenEitherValueIsEmpty() {
        // An unconfigured build expands both settings to "".
        XCTAssertNil(credentials(username: "", password: ""))
        XCTAssertNil(credentials(username: "alice", password: ""))
        XCTAssertNil(credentials(username: "", password: "s3cret"))
    }

    func testNoCredentialsWhenKeysAreMissingOrNotStrings() {
        XCTAssertNil(ServerCredentials(infoDictionary: nil))
        XCTAssertNil(ServerCredentials(infoDictionary: [:]))
        XCTAssertNil(credentials(username: 42, password: "s3cret"))
    }

    func testBundledCredentialsMatchTheAppInfoPlist() {
        XCTAssertEqual(ServerCredentials.bundled,
                       ServerCredentials(infoDictionary: Bundle.main.infoDictionary))
    }
}
