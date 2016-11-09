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

class FullScreenCameraViewController: UIViewController, ManagedObjectContextStackSettable {
	
	var managedObjectContextStack: ManagedObjectContextStack!
	var photoVideo: PhotoVideoCapture!
	
	@IBOutlet weak var cameraView: PreviewView!
	@IBOutlet weak var exitFullScreenButton: UIButton!
	@IBOutlet weak var toggleCameraOptionsButton: UIButton!
	@IBOutlet weak var cameraOptionsBar: UIView!
	@IBOutlet weak var switchFrontBackCamera: UIButton!
	@IBOutlet weak var flashOnOff: UIButton!
	@IBOutlet weak var takePhotoButton: UIButton!
	@IBOutlet weak var switchCameraMode: UIButton!
	@IBOutlet weak var livePhotoToggle: UIButton!
	
	override func viewDidLoad() {
		photoVideo = PhotoVideoCapture(delegate: self)
		openCloseCameraOptionTab()
		bringSubviewsToFront()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		photoVideo.viewAppeared()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
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
		dismiss(animated: true, completion: nil)
	}
	
	private enum CaptureMode {
		case movie
		case photo
	}
	
	private var captureMode: CaptureMode = .photo {
		didSet {
			print("\n\n CURRENT CAPTURE MODE: \(captureMode) \n\n")
		}
	}
	
	@IBAction func touchExposeButton(_ sender: AnyObject) {
		switch captureMode {
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
		
	}
	
	@IBAction func toggleRecordMovieOrPhoto(_ sender: Any) {
		photoVideo.toggleCaptureMode()
		captureMode = (captureMode == .photo) ? .movie : .photo
	}
	
	@IBAction func toggleLivePhotoOnOff(_ sender: Any) {
		photoVideo.toggleLivePhotoMode()
		//captureMode = (captureMode == .photo) ? .livePhoto : .photo
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

		UIView.animate(withDuration: 0.5, delay: 0, animations: {
			self.view.layoutIfNeeded()}, completion: { _ in
		
		let barButtonsHidden = self.switchCameraMode.isHidden
		self.switchCameraMode.isHidden = !barButtonsHidden
		self.flashOnOff.isHidden = !barButtonsHidden
		self.livePhotoToggle.isHidden = !barButtonsHidden
		self.switchFrontBackCamera.isHidden = !barButtonsHidden
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
	
	func didTakePhoto(image: UIImage, livePhoto: String?) {
		
		if let livePhoto = livePhoto {
			let player = AVPlayer(url: PhotoNote.generateLivePhotoPath(livePhotoReferenceNumber: livePhoto))
			let playerController = AVPlayerViewController()
			playerController.player = player
			self.present(playerController, animated: true) {
				playerController.player!.play()
			}
		}
	}
	func didTakeVideo(videoReferenceNumber: String) {
		
		// test that shows that video does save.
		print(MovieNote.generateMoviePath(movieReferenceNumber: videoReferenceNumber))
		let player = AVPlayer(url: MovieNote.generateMoviePath(movieReferenceNumber: videoReferenceNumber))
		let playerController = AVPlayerViewController()
		playerController.player = player
		self.present(playerController, animated: true) {
		playerController.player!.play()
		}
	}
	
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
			livePhotoToggle.isEnabled = false
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
			
		case .noLivePhotoOneCameraOnly:
			livePhotoToggle.isEnabled = false
			switchCameraMode.isEnabled = true
			takePhotoButton.isEnabled = true
			flashOnOff.isEnabled = true
			switchFrontBackCamera.isEnabled = false
		}
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
	
}
