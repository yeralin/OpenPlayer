//
//  AudioFileInfoTests.swift
//  MusicPlayerTests
//

import XCTest
@testable import MusicPlayer

final class AudioFileInfoTests: XCTestCase {

    private var directory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AudioFileInfoTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
        try super.tearDownWithError()
    }

    func testReadsTitleAndArtistTags() throws {
        let url = directory.appendingPathComponent("tagged.mp3")
        try ID3Tag.writeTaggedSong(to: url, frames: ["TIT2": "Real Title", "TPE1": "Real Artist"])

        XCTAssertEqual(AudioFileInfo.tags(of: url),
                       AudioFileInfo.Tags(title: "Real Title", artist: "Real Artist"))
    }

    func testUntaggedFileHasNoTags() {
        XCTAssertEqual(AudioFileInfo.tags(of: TestPersistence.testSongUrl), AudioFileInfo.Tags())
    }

    func testUnreadableFileHasNoTags() throws {
        let missing = directory.appendingPathComponent("missing.mp3")
        let notAudio = directory.appendingPathComponent("notes.mp3")
        try Data("not audio".utf8).write(to: notAudio)

        XCTAssertEqual(AudioFileInfo.tags(of: missing), AudioFileInfo.Tags())
        XCTAssertEqual(AudioFileInfo.tags(of: notAudio), AudioFileInfo.Tags())
    }

    func testDurationOfADecodableFile() throws {
        let seconds = try XCTUnwrap(AudioFileInfo.duration(of: TestPersistence.testSongUrl))

        XCTAssertTrue(seconds.isFinite)
        XCTAssertGreaterThan(seconds, 0)
    }

    func testNoDurationForUnreadableFiles() throws {
        let notAudio = directory.appendingPathComponent("notes.mp3")
        try Data("not audio".utf8).write(to: notAudio)

        XCTAssertNil(AudioFileInfo.duration(of: directory.appendingPathComponent("missing.mp3")))
        XCTAssertNil(AudioFileInfo.duration(of: notAudio))
    }
}
