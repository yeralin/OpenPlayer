//
//  BufferSliderTests.swift
//  MusicPlayerTests
//

import UIKit
import XCTest
@testable import MusicPlayer

final class BufferSliderTests: XCTestCase {

    private let bounds = CGRect(x: 0, y: 0, width: 200, height: 30)

    private func trackRect(_ position: VerticalPosition) -> CGRect {
        let slider = BufferSlider(frame: bounds)
        slider.borderWidth = 0.5
        slider.sliderHeight = 2
        slider.sliderPosition = position
        return slider.bufferTrackRect(in: bounds)
    }

    func testTrackIsSliderHeightTallAndSpansTheWidth() {
        for position in [VerticalPosition.top, .center, .bottom] {
            let rect = trackRect(position)
            // The height used to be the view's width (a typo), so the
            // track was 199 points tall instead of 2.
            XCTAssertEqual(rect.height, 2, "\(position)")
            XCTAssertEqual(rect.minX, 0.5, "\(position)")
            XCTAssertEqual(rect.width, 199, "\(position)")
        }
    }

    func testVerticalPositions() {
        XCTAssertEqual(trackRect(.top).minY, 0.5)
        XCTAssertEqual(trackRect(.center).midY, 15)
        // With the typo the bottom track started 169.5 points above the view.
        XCTAssertEqual(trackRect(.bottom).maxY, 29.5)
    }
}
