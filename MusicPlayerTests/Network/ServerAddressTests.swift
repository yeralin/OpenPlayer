//
//  ServerAddressTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class ServerAddressTests: XCTestCase {

    func testKeepsExplicitSchemes() {
        XCTAssertEqual(ServerAddress.normalize("http://192.168.1.5:5000"), "http://192.168.1.5:5000")
        XCTAssertEqual(ServerAddress.normalize("https://music.example"), "https://music.example")
        XCTAssertEqual(ServerAddress.normalize("HTTPS://music.example"), "HTTPS://music.example")
    }

    func testAddsHttpWhenThereIsNoScheme() {
        XCTAssertEqual(ServerAddress.normalize("192.168.1.5:5000"), "http://192.168.1.5:5000")
        XCTAssertEqual(ServerAddress.normalize("localhost:8080"), "http://localhost:8080")
    }

    func testHostsContainingHttpStillGetAScheme() {
        // The old check was `contains("http")`, which left these unusable.
        XCTAssertEqual(ServerAddress.normalize("myhttpserver.local"), "http://myhttpserver.local")
        XCTAssertEqual(ServerAddress.normalize("httpbin.local:80"), "http://httpbin.local:80")
    }

    func testTrimsWhitespace() {
        XCTAssertEqual(ServerAddress.normalize("  music.local \n"), "http://music.local")
    }

    func testBlankInputIsRejected() {
        XCTAssertNil(ServerAddress.normalize(""))
        XCTAssertNil(ServerAddress.normalize("   "))
    }
}
