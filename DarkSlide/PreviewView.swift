//
//  PreviewView.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/10/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
	
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		return layer as! AVCaptureVideoPreviewLayer
	}
	
	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
		}
	}
	
	override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
}
