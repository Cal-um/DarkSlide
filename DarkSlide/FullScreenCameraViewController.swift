//
//  FullScreenCameraViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 26/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class FullScreenCameraViewController: UIViewController {

	// MARK: ViewController Properties

	var photoVideo: PhotoVideoCapture!
	var cameraOutputDelegate: CameraOutputDelegate!

	@IBOutlet weak var cameraView: PreviewView!
	@IBOutlet weak var exitFullScreenButton: UIButton!
	@IBOutlet weak var toggleCameraOptionsButton: UIButton!
	@IBOutlet weak var cameraOptionsBar: UIView!
	@IBOutlet weak var switchFrontBackCamera: UIButton!
	@IBOutlet weak var flashOnOff: UIButton!
	@IBOutlet weak var takePhotoButton: UIButton!
	@IBOutlet weak var switchCameraMode: UIButton!
	@IBOutlet weak var livePhotoToggle: UIButton!
	@IBOutlet weak var cameraUnavailableLabel: UILabel!
	@IBOutlet weak var resumeSessionButton: UIButton!

	// MARK: Delegate properies. Used to observe state of photoVideo

	var observeLivePhotoModeSelected: LivePhotoMode = .off {
		didSet {
			switch observeLivePhotoModeSelected {
			case .off: livePhotoToggle.setTitle("live photo off", for: .normal)
			case .on: livePhotoToggle.setTitle("live photo on", for: .normal)
			}
		}
	}
	var observeFlashConfiguration: AVCaptureFlashMode = .auto {
		didSet {
			switch observeFlashConfiguration {
			case .auto:
				flashOnOff.setTitle("Auto FL", for: .normal)
			case .on:
				flashOnOff.setTitle("FL On", for: .normal)
			case .off:
				flashOnOff.setTitle("FL Off", for: .normal)
			}
		}
	}

	var observeCaptureMode: CaptureMode = .photo {
		didSet {
			switch observeCaptureMode {
			case .photo:
				switchCameraMode.setTitle("Movie", for: .normal)
				takePhotoButton.setTitle("Photo", for: .normal)
			case .movie:
				switchCameraMode.setTitle("Photo", for: .normal)
				takePhotoButton.setTitle("Video", for: .normal)
			}
		}
	}

	var observeCameraFacing: CameraFacing = .front {
		didSet {
			switch observeCameraFacing {
			case .front:
				switchFrontBackCamera.setTitle("Back", for: .normal)
				flashOnOff.isHidden = true
			case .back:
				switchFrontBackCamera.setTitle("Front", for: .normal)
				flashOnOff.isHidden = false
			}
		}
	}

	// MARK: Life cycle
	override func viewDidLoad() {
		photoVideo = PhotoVideoCapture(cameraViewDelegate: self, cameraOutputDelegate: cameraOutputDelegate)
		openCloseCameraOptionTab()
		bringSubviewsToFront()
		// The default is livePhoto off so this ensures live photo is on for capable devices
		photoVideo.toggleLivePhotoMode()
	}

	override func viewDidAppear(_ animated: Bool) {
		photoVideo.viewAppeared()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override var shouldAutorotate: Bool {
		// Disable autorotation of the interface when recording is in progress.
		if let movieFileOutput = photoVideo.movieFileOutput {
			return !movieFileOutput.isRecording
		}
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
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

	@IBAction func tapToToggleOptionTabConstraint(_ sender: AnyObject) {
		openCloseCameraOptionTab()
	}

	@IBAction func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
		print("Pinch")
		let vZoomFactor = sender.scale
		print("ZOOM HAPPENING IS OF \(vZoomFactor)")
		photoVideo.zoom(zoomFactorFromPinchGesture: vZoomFactor)	}

	override func viewDidLayoutSubviews() {
		configureButton()
	}

	@IBAction func backButton(_ sender: AnyObject) {
		photoVideo.viewDissapeared()
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func touchExposeButton(_ sender: AnyObject) {
		switch observeCaptureMode {
		case .photo:
			takePhoto()
		case .movie:
			takeMovie()
		}
	}

	@IBAction func toggleChangeCameraPosition(_ sender: Any) {
		photoVideo.changeCamera()
	}

	@IBAction func toggleFlashOrTorchOnOff(_ sender: Any) {
		photoVideo.toggleFlashMode()
	}

	@IBAction func toggleRecordMovieOrPhoto(_ sender: Any) {
		photoVideo.toggleCaptureMode()
	}

	@IBAction func toggleLivePhotoOnOff(_ sender: Any) {
		photoVideo.toggleLivePhotoMode()
	}

	@IBAction func resumeSessionAction(_ sender: Any) {
		photoVideo.resumeInterupptedSession()
	}

	func configureButton() {
		takePhotoButton.layer.cornerRadius = takePhotoButton.bounds.width / 2
		takePhotoButton.clipsToBounds = true
		takePhotoButton.layer.masksToBounds = true
		takePhotoButton.backgroundColor =  UIColor(red:0.47, green:0.85, blue:0.98, alpha:0.5)
		takePhotoButton.layer.borderColor = UIColor(red:0.47, green:0.85, blue:0.98, alpha:1.0).cgColor
		takePhotoButton.layer.borderWidth = 1
	}

	func openCloseCameraOptionTab() {

		let constraint = cameraOptionsBar.superview!.constraints.filter { $0.identifier == "height" }.first
		let multiplier: CGFloat = (cameraOptionsBar.frame.height == 0) ? 0.2 : 0
		constraint?.isActive = false
		let newConstraint = NSLayoutConstraint(item: cameraOptionsBar, attribute: .height, relatedBy: .equal, toItem: cameraOptionsBar.superview!, attribute: .height, multiplier: multiplier, constant: 0)
		newConstraint.identifier = "height"
		newConstraint.isActive = true
		let isBarOpen = (multiplier != 0) ? true : false
		//self.cameraOptionsBar.isHidden = isBarOpen ? false : true
		if isBarOpen {
			cameraOptionsBar.isHidden = false
		}

		UIView.animate(withDuration: 0.5, delay: 0, animations: {
			self.view.layoutIfNeeded()}, completion: { _ in
				if !isBarOpen {
					self.cameraOptionsBar.isHidden = true
				}

		})
	}

	func takeMovie() {
		photoVideo.toggleMovieRecording()
	}

	func takePhoto() {
		photoVideo.capturePhoto()
	}

	func bringSubviewsToFront() {

		cameraView.bringSubview(toFront: takePhotoButton)
		cameraView.bringSubview(toFront: switchCameraMode)
		cameraView.bringSubview(toFront: switchFrontBackCamera)
		cameraView.bringSubview(toFront: flashOnOff)
		cameraView.bringSubview(toFront: switchCameraMode)
		cameraView.bringSubview(toFront: livePhotoToggle)
		cameraView.bringSubview(toFront: switchCameraMode)
		cameraView.bringSubview(toFront: exitFullScreenButton)
		cameraView.bringSubview(toFront: toggleCameraOptionsButton)
		cameraView.bringSubview(toFront: exitFullScreenButton)
		cameraView.bringSubview(toFront: cameraOptionsBar)
	}
}

extension FullScreenCameraViewController: CameraViewDelegate {

	func disableButtons() {
		livePhotoToggle.isEnabled = false
		switchCameraMode.isEnabled = false
		takePhotoButton.isEnabled = false
		flashOnOff.isEnabled = false
		switchFrontBackCamera.isEnabled = false
	}

	func enableButtons(buttonconfiguration: ButtonConfiguration) {
		switch buttonconfiguration {
		case .allPossible:
			livePhotoToggle.isEnabled = true
			switchCameraMode.isEnabled = true
			takePhotoButton.isEnabled = true
			flashOnOff.isEnabled = true
			switchFrontBackCamera.isEnabled = true

		case .noLivePhoto:
			print("called")
			livePhotoToggle.isEnabled = false
			livePhotoToggle.isHidden = true
			switchCameraMode.isEnabled = true
			takePhotoButton.isEnabled = true
			flashOnOff.isEnabled = true
			switchFrontBackCamera.isEnabled = true

		case .oneCameraOnly:
			livePhotoToggle.isEnabled = true
			switchCameraMode.isEnabled = true
			takePhotoButton.isEnabled = true
			flashOnOff.isEnabled = true
			switchFrontBackCamera.isEnabled = false
			switchFrontBackCamera.isHidden = true

		case .noLivePhotoOneCameraOnly:
			livePhotoToggle.isEnabled = false
			livePhotoToggle.isHidden = true
			switchCameraMode.isEnabled = true
			takePhotoButton.isEnabled = true
			flashOnOff.isEnabled = true
			switchFrontBackCamera.isEnabled = false
			switchFrontBackCamera.isHidden = true
		}
	}

	func hideResumeButton(hide: Bool) {
		if hide {
			resumeSessionButton.isHidden = true
		} else {
			resumeSessionButton.isHidden = false
		}
	}

	func hideCameraUnavailableLabel(hide: Bool) {
		if hide {
			cameraUnavailableLabel.isHidden = true
		} else {
			cameraUnavailableLabel.isHidden = false
		}
	}

	func unableToResumeUninteruptedSessionAlert() {
		self.present(unableToResumeUninteruptedSessionAlertController(), animated: true, completion: nil)
	}

	func alertActionNoCameraPermission() {
		self.present(alertActionNoCameraPermissionAlertController(), animated: true, completion: nil)
	}
}
