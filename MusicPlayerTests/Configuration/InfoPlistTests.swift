//
//  InfoPlistTests.swift
//  MusicPlayerTests
//
//  Guards keys the app reads from its own Info.plist.
//

import XCTest

final class InfoPlistTests: XCTestCase {

    private func infoString(_ key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    func testServerCredentialKeysAreExpandedFromBuildSettings() {
        // Config/Project.xcconfig always defines both settings (empty unless
        // Config/Secrets.xcconfig overrides them), so the keys must exist and
        // must not contain an unexpanded "$(...)" reference.
        for key in ["OPServerUsername", "OPServerPassword"] {
            let value = infoString(key)
            XCTAssertNotNil(value, "\(key) is missing from Info.plist")
            XCTAssertFalse(value?.contains("$(") ?? false, "\(key) was not expanded: \(value ?? "")")
        }
    }
}
