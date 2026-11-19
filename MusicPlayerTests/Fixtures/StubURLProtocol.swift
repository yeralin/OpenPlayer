//
//  StubURLProtocol.swift
//  MusicPlayerTests
//

import Alamofire
import Foundation

/// Answers every request of a session with a canned response, so network
/// code can be tested without a server.
final class StubURLProtocol: URLProtocol {

    struct Stub {
        var statusCode = 200
        var headers = ["Content-Type": "application/json"]
        var body = Data()
    }

    private static var stub = Stub()
    private static let lock = NSLock()

    /// An Alamofire session whose requests are all answered with `stub`.
    static func session(answering stub: Stub) -> Session {
        lock.lock()
        self.stub = stub
        lock.unlock()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return Session(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lock.lock()
        let stub = Self.stub
        Self.lock.unlock()
        let response = HTTPURLResponse(url: request.url!, statusCode: stub.statusCode,
                                       httpVersion: "HTTP/1.1", headerFields: stub.headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
