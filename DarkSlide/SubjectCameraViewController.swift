//
//  SubjectCameraViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class SubjectCameraViewController: UIViewController, ManagedObjectContextStackSettable {
	
	// MARK: properties and life cycle
	var managedObjectContextStack: ManagedObjectContextStack!
	var photoVideo: PhotoVideoCapture!
	var chosenSubjectImage: UIImage!
	
	@IBOutlet weak var cameraView: PreviewView!
	@IBOutlet weak var resumeSessionButton: UIButton!
	@IBOutlet weak var takePhotoButton: UIButton!
	@IBOutlet weak var goBackButton: UIButton!
	@IBOutlet weak var cameraUnavailable: UILabel!

	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		if let videoPreviewLayerConnection = cameraView.videoPreviewLayer.connection {
			let deviceOrientation = UIDevice.current.orientation
			guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
			}
			print("CALLED \(videoPreviewLayerConnection.videoOrientation.rawValue)")
			videoPreviewLayerConnection.videoOrientation = newVideoOrientation
			print("CALLED \(videoPreviewLayerConnection.videoOrientation.rawValue)")
		}
	}
	
	override func viewDidLayoutSubviews() {
		configureButton()
	}

	override func viewDidLoad() {
		photoVideo = PhotoVideoCapture(delegate: self)
		photoVideo.toggleFlashMode()
		photoVideo.toggleFlashMode()
		print(observeFlashConfiguration)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		photoVideo.viewAppeared()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		photoVideo.viewDissapeared()
		super.viewWillDisappear(true)
	}
	
	// observer properties
	
	var observeLivePhotoModeSelected : LivePhotoMode = .off
	var observeFlashConfiguration: AVCaptureFlashMode = .auto
	var observeCaptureMode: CaptureMode = .photo
	var observeCameraFacing: CameraFacing = .front
	
	// MARK: Camera Actions
	
	@IBAction func resumeCameraSession(_ sender: Any) {
		photoVideo.resumeInterupptedSession()
	}
	
	@IBAction func dissmissViewController(_ sender: Any) {
		//self.dismiss(animated: true)
	}
	
	@IBAction func takePhoto(_ sender: Any) {
		photoVideo.capturePhoto()
	}
	
	@IBAction func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
		print("Pinch")
		let vZoomFactor = sender.scale
		print("ZOOM HAPPENING IS OF \(vZoomFactor)")
		photoVideo.zoom(zoomFactorFromPinchGesture: vZoomFactor)
	}

	// MARK: UI CODE
	
	func configureButton() {
		takePhotoButton.layer.cornerRadius = takePhotoButton.bounds.width / 2
		takePhotoButton.clipsToBounds = true
		takePhotoButton.layer.masksToBounds = true
		takePhotoButton.backgroundColor =  UIColor(red:0.47, green:0.85, blue:0.98, alpha:0.5)
		takePhotoButton.layer.borderColor = UIColor(red:0.47, green:0.85, blue:0.98, alpha:1.0).cgColor
		takePhotoButton.layer.borderWidth = 1
	}
	
	// MARK: SEGUE
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Preview Subject Photo Segue" {
			guard let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? PreviewSubjectPhotoViewController else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
			vc.subjectPhoto = chosenSubjectImage
		}
	}
}

extension SubjectCameraViewController: CameraViewDelegate {
	
	func alertActionNoCameraPermission() {
		self.present(alertActionNoCameraPermissionAlertController(), animated: true, completion: nil)
	}
	
	func unableToResumeUninteruptedSessionAlert() {
		self.present(unableToResumeUninteruptedSessionAlertController(), animated: true, completion: nil)
	}
	
	func didTakePhoto(image: UIImage, livePhoto: String?) {
		chosenSubjectImage = image
		performSegue(withIdentifier: "Preview Subject Photo Segue", sender: self)
	}
	
	func didTakeVideo(videoReferenceNumber: String) {
		//unused
	}
	
	func hideResumeButton(hide: Bool) {
		resumeSessionButton.isHidden = hide
	}
	
	func hideCameraUnavailableLabel(hide: Bool) {
		cameraUnavailable.isHidden = hide
	}
	
	func enableButtons(buttonconfiguration: ButtonConfiguration) {
		takePhotoButton.isEnabled = true
		goBackButton.isEnabled = true
	}
	
	func disableButtons() {
		takePhotoButton.isEnabled = false
		goBackButton.isEnabled = false
	}
}
