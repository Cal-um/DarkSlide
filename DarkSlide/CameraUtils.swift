//
//  CameraUtils.swift
//  DarkSlide
//
//  Created by Calum Harris on 05/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol CameraUtils: class {
	
}

extension CameraUtils {
	
	func calculateZoomResult(gestureFactor: CGFloat, lastZoomFactor: CGFloat, currentVideoZoomFactor: CGFloat, maxZoomFactor: CGFloat) -> CGFloat {
		var result: CGFloat
		
		switch gestureFactor {
		case let factor where factor >= lastZoomFactor:
			print("Zoom In")
			result = gestureFactor
		case let factor where factor <= lastZoomFactor:
			print("Zoom Out")
			result = gestureFactor * -1
		default: fatalError("Durp")
		}
		
		let newVideoZoomFactor = result + currentVideoZoomFactor
		
		switch newVideoZoomFactor {
		case let factor where factor >= maxZoomFactor:
			return maxZoomFactor
		case let factor where factor <= 1:
			return 1.0
		default:
			return newVideoZoomFactor
		}
	}
}
