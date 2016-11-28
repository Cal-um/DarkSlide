//
//  CameraUtils.swift
//  DarkSlide
//
//  Created by Calum Harris on 05/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraUtils: class {

}

// This protocol was created to make it easier to test the functions. See DarkSlide Tests.

extension CameraUtils {

	func calculateZoomResult(gestureFactor: CGFloat, lastZoomFactor: CGFloat, currentVideoZoomFactor: CGFloat, maxZoomFactor: CGFloat) -> CGFloat {

		var result: CGFloat

		switch gestureFactor {
		case let factor where factor > lastZoomFactor:
			print("Zoom In")
			result = gestureFactor
		case let factor where factor <= lastZoomFactor:
			print("Zoom Out")
			result = gestureFactor * -1
		default: fatalError("Something is wrong with the calculation")
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

	func buttonConfigForObserver(isLivePhotoEnabledAndSupported: Bool, doesDeviceHaveMoreThanOneCamera: Bool) -> ButtonConfiguration {

		if isLivePhotoEnabledAndSupported && doesDeviceHaveMoreThanOneCamera {
			return .allPossible
		} else if isLivePhotoEnabledAndSupported && !doesDeviceHaveMoreThanOneCamera {
			return .oneCameraOnly
		} else if !isLivePhotoEnabledAndSupported && doesDeviceHaveMoreThanOneCamera {
			return .noLivePhoto
		} else {
			return .noLivePhotoOneCameraOnly
		}
	}
}

enum ButtonConfiguration {
	case allPossible
	case noLivePhoto
	case oneCameraOnly
	case noLivePhotoOneCameraOnly
}

extension UIInterfaceOrientation {
	var videoOrientation: AVCaptureVideoOrientation? {
		switch self {
		case .portrait: return .portrait
		case .portraitUpsideDown: return .portraitUpsideDown
		case .landscapeLeft: return .landscapeLeft
		case .landscapeRight: return .landscapeRight
		default: return nil
		}
	}
}

extension UIDeviceOrientation {
	var videoOrientation: AVCaptureVideoOrientation? {
		switch self {
		case .portrait: return .portrait
		case .portraitUpsideDown: return .portraitUpsideDown
		case .landscapeLeft: return .landscapeRight
		case .landscapeRight: return .landscapeLeft
		default: return nil
		}
	}
}

extension AVCaptureDeviceDiscoverySession {
	func uniqueDevicePositionsCount() -> Int {
		var uniqueDevicePositions = [AVCaptureDevicePosition]()
		for device in devices {
			if !uniqueDevicePositions.contains(device.position) {
				uniqueDevicePositions.append(device.position)
			}
		}
		return uniqueDevicePositions.count
	}
}
