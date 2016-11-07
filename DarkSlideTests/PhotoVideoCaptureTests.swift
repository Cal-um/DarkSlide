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
    
	/*func testIncreasingZoom() {
		//calculateZoomResult(gestureFactor: 0.3, lastZoomFactor: 0.2, currentVideoZoomFactor: 4.5, maxZoomFactor: 6)
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(0.30) / 20), lastZoomFactor: CGFloat(0.20 / 20), currentVideoZoomFactor: CGFloat(4.50), maxZoomFactor: CGFloat(6.00))
		
		let correctCalc = CGFloat((0.30/20)) + CGFloat(4.50)
		
		XCTAssertEqual(zoom, correctCalc)
	}*/
	
	func testReducingZoom() {
		
		let zoom = calculateZoomResult(gestureFactor: (CGFloat(0.30) / 20), lastZoomFactor: CGFloat(0.40 / 20), currentVideoZoomFactor: CGFloat(4.50), maxZoomFactor: CGFloat(6.00))
		
		let correctCalc = CGFloat((0.30/20)) - CGFloat(4.50)
		
		XCTAssertEqual(zoom, correctCalc)
	}
}
