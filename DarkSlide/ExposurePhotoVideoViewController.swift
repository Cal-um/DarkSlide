//
//  ExposurePhotoVideoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class ExposurePhotoVideoViewController: UIViewController, ManagedObjectContextStackSettable, CameraViewDelegate {
	
	var managedObjectContextStack: ManagedObjectContextStack!
	
	@IBOutlet weak var cameraView: UIView!
	var photoVideo: PhotoAudioVideo!
	
	override func viewDidLoad() {
		photoVideo = PhotoAudioVideo(cameraViewDelegate: self)
		gesturesForPhotoVideo()
	}
	
	override func viewDidLayoutSubviews() {
		if photoVideo.previewLayer != nil {
			photoVideo.previewLayer.frame = cameraView.bounds
			photoVideo.previewLayer.connection.videoOrientation = currentVideoOrientation()
		}
	}
	
	func currentVideoOrientation() -> AVCaptureVideoOrientation {
		var orientation: AVCaptureVideoOrientation
		
		switch UIDevice.current.orientation {
		case .portrait:
			orientation = AVCaptureVideoOrientation.portrait
		case .landscapeRight:
			orientation = AVCaptureVideoOrientation.landscapeLeft
		case .portraitUpsideDown:
			orientation = AVCaptureVideoOrientation.portraitUpsideDown
		default:
			orientation = AVCaptureVideoOrientation.landscapeRight
		}
		
		return orientation
	}
	
	func takePhoto() {
		photoVideo.takePhoto()
	}
	
	func takeVideo() {
		print("video")
	}
	
	func gesturesForPhotoVideo() {
		//Add Gesture Recodnizers for photo and video tap.
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ExposurePhotoVideoViewController.takePhoto))
		let tapAndHoldGesture = UILongPressGestureRecognizer(target: self, action: #selector(ExposurePhotoVideoViewController.takeVideo))
		tapGesture.numberOfTapsRequired = 1
		cameraView.addGestureRecognizer(tapGesture)
		cameraView.addGestureRecognizer(tapAndHoldGesture)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case .some("ExposureAudioRecordViewControllerSegue"):
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		default: break
		}
	}
}

