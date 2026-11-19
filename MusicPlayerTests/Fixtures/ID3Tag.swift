//
//  ID3Tag.swift
//  MusicPlayerTests
//
//  Builds minimal ID3v2.3 tags, so tests can create mp3 files with known
//  metadata from the untagged bundled test mp3.
//

import Foundation

enum ID3Tag {

    /// An ID3v2.3 tag with the given text frames, e.g. ["TIT2": "Title",
    /// "TPE1": "Artist"]. Text is written as ISO-8859-1.
    static func make(_ frames: [String: String]) -> Data {
        var body = Data()
        for (id, text) in frames.sorted(by: { $0.key < $1.key }) {
            precondition(id.utf8.count == 4, "ID3 frame ids are four characters")
            let content = Data([0x00]) + (text.data(using: .isoLatin1) ?? Data())
            body.append(Data(id.utf8))
            body.append(bigEndian(content.count)) // v2.3 frame sizes are plain big-endian
            body.append(contentsOf: [0x00, 0x00]) // frame flags
            body.append(content)
        }
        var tag = Data("ID3".utf8)
        tag.append(contentsOf: [0x03, 0x00, 0x00]) // version 2.3.0, no flags
        tag.append(synchsafe(body.count))
        tag.append(body)
        return tag
    }

    /// Writes the bundled test mp3 with `frames` prepended as an ID3 tag.
    static func writeTaggedSong(to url: URL, frames: [String: String]) throws {
        let audio = try Data(contentsOf: TestPersistence.testSongUrl)
        try (make(frames) + audio).write(to: url)
    }

    private static func bigEndian(_ value: Int) -> Data {
        Data([24, 16, 8, 0].map { UInt8((value >> $0) & 0xFF) })
    }

    /// Tag sizes use 7 bits per byte so they never look like an MPEG sync word.
    private static func synchsafe(_ value: Int) -> Data {
        Data([21, 14, 7, 0].map { UInt8((value >> $0) & 0x7F) })
    }
}
