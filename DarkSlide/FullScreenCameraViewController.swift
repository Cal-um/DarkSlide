//
//  FullScreenCameraViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 26/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class FullScreenCameraViewController: UIViewController {
	
	@IBOutlet weak var cameraView: UIView!
	@IBOutlet weak var cameraOptionsBar: UIView!
	@IBOutlet weak var switchFrontBackCamera: UIButton!
	@IBOutlet weak var flashOnOff: UIButton!
	@IBOutlet weak var takePhotoButton: UIButton!
	@IBOutlet weak var switchCameraMode: UIButton!
	@IBOutlet weak var livePhotoToggle: UIButton!
	
	@IBAction func tapToToggleOptionTabConstraint(_ sender: AnyObject) {
		openCloseCameraOptionTab()
	}
	
	override func viewDidLoad() {
		openCloseCameraOptionTab()
	}
	
	override func viewDidLayoutSubviews() {
		configureButton()
	}
	
	@IBAction func backButton(_ sender: AnyObject) {
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
	
	
}
