//
//  SubjectCameraViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class SubjectCameraViewController: UIViewController, ManagedObjectContextStackSettable {

	// MARK: properties and life cycle
	var locationManager: CLLocationManager!
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

		if let videoPreviewLayerConnection = cameraView?.videoPreviewLayer.connection {
			let deviceOrientation = UIDevice.current.orientation
			guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
			}
			videoPreviewLayerConnection.videoOrientation = newVideoOrientation
		}
	}

	override func viewDidLayoutSubviews() {
		configureButton()
	}

	override func viewDidLoad() {
		photoVideo = PhotoVideoCapture(cameraViewDelegate: self, cameraOutputDelegate: self)
		photoVideo.toggleFlashMode()
		photoVideo.toggleFlashMode()
		print(observeFlashConfiguration)
		locationManager = CLLocationManager()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		photoVideo.viewAppeared()
		configureLocationManager()
	}

	override func viewWillDisappear(_ animated: Bool) {
		photoVideo.viewDissapeared()
		locationManager.stopUpdatingHeading()
		locationManager.stopUpdatingLocation()
		super.viewWillDisappear(true)
	}

	// observer properties

	var observeLivePhotoModeSelected: LivePhotoMode = .off
	var observeFlashConfiguration: AVCaptureFlashMode = .auto
	var observeCaptureMode: CaptureMode = .photo
	var observeCameraFacing: CameraFacing = .front

	// MARK: Camera Actions

	@IBAction func resumeCameraSession(_ sender: Any) {
		photoVideo.resumeInterupptedSession()
	}

	@IBAction func dissmissViewController(_ sender: Any) {
		self.dismiss(animated: true)
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

	// MARK: Location and heading variables

	fileprivate var coordinates: CLLocationCoordinate2D? {
		didSet {
			print("COORDINATES: LAT \(coordinates?.latitude) LONG: \(coordinates?.longitude)")
		}
	}

	private var correctedScreenOrientationHeading: Double? {
		didSet {
			print(correctedScreenOrientationHeading)
		}
	}

	fileprivate var heading: Double? {
		// The Compass heading is taken from the top of the device no matter what the screen orientation is. To correct the measurements in the event of an orientation change this is corrected with the below didSet.

		didSet {
			guard let currentScreenOrientation = cameraView?.videoPreviewLayer.connection?.videoOrientation, let heading = heading else { return }

			switch currentScreenOrientation {
			case .portrait: correctedScreenOrientationHeading = heading
			case .landscapeRight: correctedScreenOrientationHeading = heading + 90
			case .landscapeLeft: correctedScreenOrientationHeading = heading - 90
			case .portraitUpsideDown:
				if heading > 180 {
					correctedScreenOrientationHeading = heading + 180 - 360
				} else {
					correctedScreenOrientationHeading = 360 - (180 - heading)
				}
			}
		}
	}

	// MARK: UI CODE

	private func configureButton() {
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

			if let coordinates = coordinates {
				vc.latitude = coordinates.latitude
				vc.longitude = coordinates.longitude
			}

			if let heading = heading {
				vc.compassHeading = heading
			}
		}
	}
}

extension SubjectCameraViewController: CameraViewDelegate, CameraOutputDelegate {

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

extension SubjectCameraViewController: CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
			heading = newHeading.trueHeading
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		coordinates = locations.last?.coordinate
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}

	func checkLocationManagerAuthorisationStatus() {
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined: locationManager.requestWhenInUseAuthorization()
		case .denied, .restricted: self.present(noPermissionLocationServicesAlertController(), animated: true, completion: nil)
		default: break
		}
	}

	func noPermissionLocationServicesAlertController() -> UIAlertController {
		let message = "Dark Slide doesn't have permission to use Location Services, please change privacy settings"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { action in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
		}))
		return alertController
	}

	func configureLocationManager() {
		checkLocationManagerAuthorisationStatus()
		locationManager.delegate = self
		locationManager.startUpdatingHeading()
		locationManager.startUpdatingLocation()

	}
}
