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

class ExposurePhotoVideoViewController: UIViewController, ManagedObjectContextStackSettable {
	
	// MARK: View Controller properties and life cycle
	
	var managedObjectContextStack: ManagedObjectContextStack!
	
	@IBOutlet weak var cameraView: PreviewView!
	
	var photoVideo: PhotoVideoCapture!
	
	override func viewDidLoad() {
		// set up video preview and PhotoAudioVideo object
		photoVideo = PhotoVideoCapture(delegate: self)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		photoVideo.viewAppeared()
	//	setUpInitialVideoOrientation()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		photoVideo.viewDissapeared()
	}
	
	@IBOutlet weak var takeExposureButton: UIButton!
	
	@IBAction func tapExposureButton(_ sender: Any) {
		takePhoto()
	}
	
	
	func takePhoto() {
			photoVideo.capturePhoto()
	}
	

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case .some("AudioSegue"):
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		case .some("FullViewSegue"):
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		default: break
		}
	}
}

extension ExposurePhotoVideoViewController: CameraViewDelegate {
	
	func disableButtons() {
		takeExposureButton.isEnabled = false
	}
	
	func enableButtons(buttonconfiguration: ButtonConfiguration) {
			takeExposureButton.isEnabled = true
	}
	
	func alertActionNoCameraPermission() {
		let message = "Dark Slide doesn't have permission to use the camera, please change privacy settings"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { action in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
		}))
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	// Unused in ExposureViewController
	func didTakeVideo(videoReferenceNumber: String) {
		
	}
	
	func didTakePhoto(image: UIImage, livePhoto: String?) {
		print(image)
	}
}



