//
//  MPControlSeekTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class MPControlSeekTests: XCTestCase {

    private var control: MPControl!

    override func setUp() {
        super.setUp()
        control = MPControl(resumeSong: {}, pauseSong: {}, isPlaying: { false },
                            playNextSong: {}, playPreviousSong: {}, seekFor: { _, _ in })
    }

    override func tearDown() {
        control.endSeeking()
        control = nil
        super.tearDown()
    }

    /// Waits on the main run loop, which the seek worker needs: it performs
    /// each seek with `DispatchQueue.main.sync`.
    private func waitUntil(timeout: TimeInterval = 5, _ condition: @escaping () -> Bool) {
        let done = expectation(description: "condition")
        func poll() {
            if condition() {
                done.fulfill()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: poll)
            }
        }
        poll()
        wait(for: [done], timeout: timeout)
    }

    func testBeginSeekingSeeksRightAwayInTheRequestedDirection() {
        var seeks: [(seconds: Double, forward: Bool)] = []

        control.beginSeeking(seekFor: { seconds, forward in seeks.append((seconds, forward)) },
                             forward: true)

        // Before the fix the worker could start before `seekWorker` was set,
        // see nil and exit without seeking at all.
        waitUntil { !seeks.isEmpty }
        XCTAssertEqual(seeks.first?.seconds, 5)
        XCTAssertEqual(seeks.first?.forward, true)
    }

    func testEndSeekingStopsTheWorker() {
        var seekCount = 0
        control.beginSeeking(seekFor: { _, _ in seekCount += 1 }, forward: false)
        waitUntil { seekCount > 0 }

        control.endSeeking()

        waitUntil { self.control.seekWorker == nil }
        let countAfterStop = seekCount
        let settle = expectation(description: "no more seeks")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { settle.fulfill() }
        wait(for: [settle], timeout: 3)
        XCTAssertEqual(seekCount, countAfterStop)
    }

    func testSeekFailureStopsTheWorkerInsteadOfCrashing() {
        // AudioPlayer.seekFor throws once playback stops. The worker used
        // `try!`, so stopping while the seek button was held crashed the app.
        var attempts = 0
        control.beginSeeking(seekFor: { _, _ in
            attempts += 1
            throw "Could not locate an active player, nothing to seek"
        }, forward: true)

        waitUntil { attempts > 0 && self.control.seekWorker == nil }
        XCTAssertEqual(attempts, 1)
    }
}
