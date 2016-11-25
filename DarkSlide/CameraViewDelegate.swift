//
//  PreviewLayerDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate: class {

	weak var cameraView: PreviewView! { get set }

	// settings observers
	var observeLivePhotoModeSelected: LivePhotoMode { get set }
	var observeFlashConfiguration: AVCaptureFlashMode { get set }
	var observeCameraFacing: CameraFacing { get set }
	var observeCaptureMode: CaptureMode { get set }

	func disableButtons()
	func alertActionNoCameraPermission()
	func unableToResumeUninteruptedSessionAlert()
	func hideResumeButton(hide: Bool)
	func hideCameraUnavailableLabel(hide: Bool)
	func enableButtons(buttonconfiguration: ButtonConfiguration)

	func didTakePhoto(image: UIImage, livePhoto: String?)
	func didTakeVideo(videoReferenceNumber: String)

	// TODO: Refactor methods into protocol extension.

}

extension CameraViewDelegate {

	func alertActionNoCameraPermissionAlertController() -> UIAlertController {
		let message = "Dark Slide doesn't have permission to use the camera, please change privacy settings"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { action in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
		}))
		return alertController
	}

	func unableToResumeUninteruptedSessionAlertController() -> UIAlertController {
		let message = "Unable to resume"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		return alertController
	}
}

enum LivePhotoMode {
	case on
	case off
}

enum CaptureMode {
	case photo
	case movie
}

enum CameraFacing {
	case front
	case back
}
