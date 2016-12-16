//
//  SubjectCameraModel.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

struct SubjectCameraModel {

	static func correctHeading(screenOrientation: AVCaptureVideoOrientation, heading: Double) -> Double {

		switch screenOrientation {
		case .portrait: return heading
		case .landscapeRight:
			switch heading {
			case 270..<360:
				let sum = 360 - heading
				return 90 - sum
			default: return heading + 90
			}
		case .landscapeLeft:
			switch heading {
			case 0..<90:
				let sum = 90 - heading
				return 360 - sum
			default: return heading - 90
			}

		case .portraitUpsideDown:
			if heading > 180 {
				return heading + 180 - 360
			} else {
				return 360 - (180 - heading)
			}
		}
	}
}
