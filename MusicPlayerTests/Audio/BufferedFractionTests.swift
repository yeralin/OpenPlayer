//
//  BufferedFractionTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class BufferedFractionTests: XCTestCase {

    private func fraction(_ downloaded: Int, of expected: Int) -> Double {
        RemotePlayerItem.bufferedFraction(downloaded: downloaded, expected: expected)
    }

    func testFractionOfAKnownSize() {
        XCTAssertEqual(fraction(0, of: 1_000), 0)
        XCTAssertEqual(fraction(250, of: 1_000), 0.25)
        XCTAssertEqual(fraction(1_000, of: 1_000), 1)
    }

    func testIsNotRoundedToWholePercents() {
        // The old formula did integer maths and reported 0.01 here.
        XCTAssertEqual(fraction(15, of: 1_000), 0.015, accuracy: 1e-9)
    }

    func testUnknownSizeDoesNotCrash() {
        // URLSession reports -1 when there is no Content-Length. The old
        // formula divided by (-1 / 100) == 0 and crashed.
        XCTAssertEqual(fraction(4_096, of: Int(NSURLSessionTransferSizeUnknown)), 0)
    }

    func testFilesSmallerThan100BytesDoNotCrash() {
        // The old formula divided by (expected / 100) == 0 here too.
        XCTAssertEqual(fraction(10, of: 0), 0)
        XCTAssertEqual(fraction(10, of: 40), 0.25)
    }

    func testNeverExceedsOne() {
        XCTAssertEqual(fraction(2_000, of: 1_000), 1)
    }
}
