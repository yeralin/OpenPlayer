//
//  BackgroundSessionCompletionTests.swift
//  MusicPlayerTests
//

import UIKit
import XCTest
@testable import MusicPlayer

final class BackgroundSessionCompletionTests: XCTestCase {

    private var sessions: [URLSession] = []

    override func tearDown() {
        sessions.forEach { $0.invalidateAndCancel() }
        sessions.removeAll()
        super.tearDown()
    }

    private func backgroundSession() -> URLSession {
        let identifier = "OpenPlayerTests.\(UUID().uuidString)"
        let session = URLSession(configuration: .background(withIdentifier: identifier))
        sessions.append(session)
        return session
    }

    func testFinishingEventsCallsTheStoredHandlerOnMain() {
        let session = backgroundSession()
        let identifier = session.configuration.identifier!
        let called = expectation(description: "completion handler")
        BackgroundSessionCompletion.shared.store({
            XCTAssertTrue(Thread.isMainThread)
            called.fulfill()
        }, forSession: identifier)

        // Used to be stored by AppDelegate and never called.
        AudioDownloadDelegate().urlSessionDidFinishEvents(forBackgroundURLSession: session)

        wait(for: [called], timeout: 1)
    }

    func testHandlerIsCalledOnlyOnce() {
        let session = backgroundSession()
        let identifier = session.configuration.identifier!
        var calls = 0
        let called = expectation(description: "completion handler")
        BackgroundSessionCompletion.shared.store({ calls += 1; called.fulfill() }, forSession: identifier)

        BackgroundSessionCompletion.shared.complete(session: identifier)
        BackgroundSessionCompletion.shared.complete(session: identifier)

        wait(for: [called], timeout: 1)
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 1)
        XCTAssertEqual(calls, 1)
    }

    func testOtherSessionsHandlersAreLeftAlone() {
        let finished = backgroundSession()
        let other = backgroundSession()
        let notCalled = expectation(description: "other session's handler")
        notCalled.isInverted = true
        BackgroundSessionCompletion.shared.store({ notCalled.fulfill() },
                                                 forSession: other.configuration.identifier!)

        AudioDownloadDelegate().urlSessionDidFinishEvents(forBackgroundURLSession: finished)

        wait(for: [notCalled], timeout: 0.3)
        BackgroundSessionCompletion.shared.complete(session: other.configuration.identifier!)
    }

    func testAppDelegateHandsTheHandlerOver() throws {
        let appDelegate = try XCTUnwrap(UIApplication.shared.delegate as? AppDelegate)
        let identifier = "OpenPlayerTests.\(UUID().uuidString)"
        let called = expectation(description: "completion handler")

        appDelegate.application(UIApplication.shared,
                                handleEventsForBackgroundURLSession: identifier,
                                completionHandler: { called.fulfill() })
        BackgroundSessionCompletion.shared.complete(session: identifier)

        wait(for: [called], timeout: 1)
    }
}
