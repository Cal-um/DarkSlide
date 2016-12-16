//
//  SubjectCameraModelTests.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import XCTest
@testable import DarkSlide

class SubjectCameraModelTests: XCTestCase {


	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testPortrait() {
		let corrected = SubjectCameraModel.correctHeading(screenOrientation: .portrait, heading: 40.0)
		XCTAssertEqual(corrected, 40.0)
	}

	func testLandscapeLeft() {
		let corrected = SubjectCameraModel.correctHeading(screenOrientation: .landscapeLeft, heading: 30)

		XCTAssertEqual(corrected, 300)
	}
	
	func testLandscapeLeft2() {
		let corrected = SubjectCameraModel.correctHeading(screenOrientation: .landscapeLeft, heading: 89.4)
		
		XCTAssertEqual(corrected, 359.4)
	}
	
	func testLandscapeLeft3() {
		let corrected = SubjectCameraModel.correctHeading(screenOrientation: .landscapeLeft, heading: 90)
		
		XCTAssertEqual(corrected, 0)
	}

	func testLandscaperRight() {
		let corrected = SubjectCameraModel.correctHeading(screenOrientation: .landscapeRight, heading: 355)

		XCTAssertEqual(corrected, 85)
	}
	
	func testLandscaperRight2() {
		let corrected = SubjectCameraModel.correctHeading(screenOrientation: .landscapeRight, heading: 270.0)
		
		XCTAssertEqual(corrected, 0)
	}

}
