//
//  AudioFileInfo.swift
//  MusicPlayer
//
//  Synchronous reads of a local audio file's metadata, without the AVAsset
//  property getters (commonMetadata, duration) deprecated in iOS 16.
//

import AudioToolbox

enum AudioFileInfo {

    struct Tags: Equatable {
        var title: String?
        var artist: String?
    }

    /// Title and artist tags (ID3 for mp3, iTunes atoms for m4a, ...), read
    /// through Audio File Services' info dictionary. Empty when the file
    /// cannot be opened or has no tags.
    static func tags(of url: URL) -> Tags {
        var fileID: AudioFileID?
        guard AudioFileOpenURL(url as CFURL, .readPermission, 0, &fileID) == noErr,
              let file = fileID else {
            return Tags()
        }
        defer { AudioFileClose(file) }

        // The property hands back a retained CFDictionary.
        var info: Unmanaged<CFDictionary>?
        var size = UInt32(MemoryLayout<Unmanaged<CFDictionary>?>.size)
        guard AudioFileGetProperty(file, kAudioFilePropertyInfoDictionary, &size, &info) == noErr,
              let dictionary = info?.takeRetainedValue() as? [String: Any] else {
            return Tags()
        }
        return Tags(title: nonEmpty(dictionary[kAFInfoDictionary_Title]),
                    artist: nonEmpty(dictionary[kAFInfoDictionary_Artist]))
    }

    private static func nonEmpty(_ value: Any?) -> String? {
        guard let text = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }
}
