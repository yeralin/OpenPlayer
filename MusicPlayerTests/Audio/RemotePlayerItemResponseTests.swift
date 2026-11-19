//
//  RemotePlayerItemResponseTests.swift
//  MusicPlayerTests
//

import AVFoundation
import XCTest
@testable import MusicPlayer

final class RemotePlayerItemResponseTests: PersistenceTestCase {

    private func response(_ headers: [String: String]) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "http://127.0.0.1:9/song.mp3")!, statusCode: 200,
                        httpVersion: "HTTP/1.1", headerFields: headers)!
    }

    func testDownloadDelegatePostsReceivedHttpResponse() {
        let item = RemotePlayerItem(song: persistence.makeRemoteSong())
        let delegate = item.audioDownloadDelegate
        let session = URLSession(configuration: .ephemeral)
        defer { session.invalidateAndCancel() }
        let task = session.dataTask(with: item.url) // never resumed
        let posted = expectation(forNotification: .receivedHttpResponse, object: item)

        // AudioPlayer listens for this to apply the Audio-Duration header,
        // but nothing used to post it.
        delegate.urlSession(session, dataTask: task,
                            didReceive: response(["Audio-Duration": "215"])) { _ in }

        wait(for: [posted], timeout: 1)
        XCTAssertEqual(item.httpResponse?.statusCode, 200)
    }

    func testAudioDurationHeaderSetsTheDuration() {
        let item = RemotePlayerItem(song: persistence.makeRemoteSong())

        XCTAssertTrue(item.applyDurationHeader(from: response(["Audio-Duration": "215.5"])))
        XCTAssertEqual(item.duration.seconds, 215.5, accuracy: 0.01)
    }

    func testAudioDurationHeaderNameIsCaseInsensitive() {
        let item = RemotePlayerItem(song: persistence.makeRemoteSong())

        XCTAssertTrue(item.applyDurationHeader(from: response(["audio-duration": "60"])))
        XCTAssertEqual(item.duration.seconds, 60, accuracy: 0.01)
    }

    func testMissingOrInvalidAudioDurationIsIgnored() {
        let item = RemotePlayerItem(song: persistence.makeRemoteSong())

        for headers in [[:], ["Audio-Duration": "abc"], ["Audio-Duration": "0"], ["Audio-Duration": "-3"]] {
            XCTAssertFalse(item.applyDurationHeader(from: response(headers)), "\(headers)")
        }
        XCTAssertEqual(item.duration.seconds, 0)
    }
}
