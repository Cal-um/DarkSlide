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
