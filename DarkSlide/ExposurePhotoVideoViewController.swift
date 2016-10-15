//
//  ExposurePhotoVideoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import AVKit

class ExposurePhotoVideoViewController: UIViewController, ManagedObjectContextStackSettable, CameraViewDelegate {
	
	// MARK: View Controller properties and life cycle
	
	
	var managedObjectContextStack: ManagedObjectContextStack!
	
	@IBOutlet weak var cameraView: UIView!
	
	var photoVideo: PhotoAudioVideo!
	
	override func viewDidLoad() {
		// set up video preview and PhotoAudioVideo object
		photoVideo = PhotoAudioVideo(cameraViewDelegate: self, managedObjectContextStack: managedObjectContextStack, configuration: .livePhotoOnly)
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
	
	@IBAction func shortPress(_ sender: UITapGestureRecognizer) {
		photoVideo.takePhoto()

	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case .some("AudioSegue"):
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		case .some("FullViewSegue"):
			print("good")
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		default: break
		}
	}
}

