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
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
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
	
	override func layoutSubviews() {
		super.layoutSubviews()
		print("bounds: \(bounds)")
		print("frame: \(videoPreviewLayer.frame)")
		videoPreviewLayer.frame = bounds
	}
	
	private func setup() {
		backgroundColor = UIColor.black
	}
}
