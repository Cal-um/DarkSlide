//
//  PreviewLayerDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol CameraViewDelegate: class {
	
	weak var cameraView: PreviewView! { get set }
	
	func disableButtons()
	func alertActionNoCameraPermission()
	func enableButtons(buttonconfiguration: ButtonConfiguration)
	
	func didTakePhoto(image: UIImage, livePhoto: String?)
	func didTakeVideo(videoReferenceNumber: String)
}
