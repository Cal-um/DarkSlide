//
//  DarkSlideTests.swift
//  DarkSlideTests
//
//  Created by Calum Harris on 04/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import XCTest
@testable import DarkSlide

class PhotoVideoCaptureTests: XCTestCase, CameraUtils {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	// MARK: ZOOM TESTS
	// tests use a scaled factor of 0.05 and max limit 6.0

	func testIncreasingZoom() {
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(0.30) / 20), lastZoomFactor: CGFloat(0.20 / 20), currentVideoZoomFactor: CGFloat(4.50), maxZoomFactor: CGFloat(6.00))

		let correctCalc = CGFloat((0.30/20)) + CGFloat(4.50)

		XCTAssertEqual(zoom, correctCalc)
	}

	func testReducingZoom() {

		let zoom = calculateZoomResult(gestureFactor: (CGFloat(0.30) / 20), lastZoomFactor: CGFloat(0.40 / 20), currentVideoZoomFactor: CGFloat(4.50), maxZoomFactor: CGFloat(6.00))

		let correctCalc = CGFloat(4.50) - CGFloat((0.30/20))

		XCTAssertEqual(zoom, correctCalc)
	}

	func testMinLimitReducing() {
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(0.40) / 20), lastZoomFactor: CGFloat(0.50 / 20), currentVideoZoomFactor: CGFloat(0.03), maxZoomFactor: CGFloat(6.00))

		XCTAssertEqual(zoom, 1.0)

	}

	func testMinLimitWhenAtCurrentZoomAt1() {
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(1.6) / 20), lastZoomFactor: CGFloat(1.7 / 20), currentVideoZoomFactor: CGFloat(1.0), maxZoomFactor: CGFloat(6.00))

		XCTAssertEqual(zoom, 1.0)
	}

	func testMaxLimitZoom() {
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(1.6) / 20), lastZoomFactor: CGFloat(1.5 / 20), currentVideoZoomFactor: CGFloat(5.95), maxZoomFactor: CGFloat(6.00))

		XCTAssertEqual(zoom, 6.0)
	}

	func testMaxLimitZoomWhenCurrentZoomAt6() {
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(1.6) / 20), lastZoomFactor: CGFloat(1.5 / 20), currentVideoZoomFactor: CGFloat(6.0), maxZoomFactor: CGFloat(6.00))

		XCTAssertEqual(zoom, 6.0)
	}

	// MARK: Observer Value Button Config Tests

	func testLivePhotoAndMoreThanOneCamera() {
		let buttonConfig = buttonConfigForObserver(isLivePhotoEnabledAndSupported: true, doesDeviceHaveMoreThanOneCamera: true)

		XCTAssertEqual(buttonConfig, .allPossible)
	}

	func testLivePhotoOnlyOneCamera() {
		let buttonConfig = buttonConfigForObserver(isLivePhotoEnabledAndSupported: true, doesDeviceHaveMoreThanOneCamera: false)

		XCTAssertEqual(buttonConfig, .oneCameraOnly)
	}

	func testNoLivePhotoMoreThanOneCamera() {
		let buttonConfig = buttonConfigForObserver(isLivePhotoEnabledAndSupported: false, doesDeviceHaveMoreThanOneCamera: true)

		XCTAssertEqual(buttonConfig, .noLivePhoto)
	}

	func testNoLivePhotoOnlyOneCamera() {
		let buttonConfig = buttonConfigForObserver(isLivePhotoEnabledAndSupported: false, doesDeviceHaveMoreThanOneCamera: false)

		XCTAssertEqual(buttonConfig, .noLivePhotoOneCameraOnly)

	}

}
