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

class FullScreenCameraViewController: UIViewController, ManagedObjectContextStackSettable, CameraViewDelegate {
	
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
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		if let videoPreviewLayerConnection = cameraView.videoPreviewLayer.connection {
			let deviceOrientation = UIDevice.current.orientation
			guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
			}
			
			videoPreviewLayerConnection.videoOrientation = newVideoOrientation
		}
	}
	
	@IBAction func takeVideo(_ sender: AnyObject) {
		takeVideo()
	}
	
	@IBAction func tapToToggleOptionTabConstraint(_ sender: AnyObject) {
		openCloseCameraOptionTab()
	}
	
	override func viewDidLayoutSubviews() {
		configureButton()
	}
	
	@IBAction func backButton(_ sender: AnyObject) {
		photoVideo.viewDissapeared()
		dismiss(animated: true, completion: nil)
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
	
	func takeVideo() {
		print("video")
	}
	
	func didTakeLivePhoto(image: UIImage, video: Data) {
		
	}
	
	func didTakeVideo(video: Data) {
		
	}
	
	func didTakeImage(image: UIImage) {
		
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
