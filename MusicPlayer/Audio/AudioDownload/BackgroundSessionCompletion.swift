//
//  BackgroundSessionCompletion.swift
//  MusicPlayer
//

import Foundation

/// Holds the completion handlers iOS passes to
/// `application(_:handleEventsForBackgroundURLSession:completionHandler:)`
/// until the matching background `URLSession` has delivered all its events.
///
/// iOS expects each handler to be called (on the main queue) once the session
/// reports `urlSessionDidFinishEvents(forBackgroundURLSession:)`. That lets it
/// take a new app snapshot and suspend the app again; an uncalled handler
/// keeps the app awake and counts against its background budget.
final class BackgroundSessionCompletion {

    static let shared = BackgroundSessionCompletion()

    private var handlers: [String: () -> Void] = [:]
    private let lock = NSLock()

    func store(_ handler: @escaping () -> Void, forSession identifier: String) {
        lock.lock()
        defer { lock.unlock() }
        handlers[identifier] = handler
    }

    /// Calls and forgets the handler for `identifier`, on the main queue.
    func complete(session identifier: String) {
        lock.lock()
        let handler = handlers.removeValue(forKey: identifier)
        lock.unlock()
        guard let handler = handler else {
            return
        }
        DispatchQueue.main.async(execute: handler)
    }
}
