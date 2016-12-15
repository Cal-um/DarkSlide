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

	var videoPreviewLayer: AVCaptureVideoPreviewLayer!

	var shutterSimulation: UIView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	func setupForPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		layer.insertSublayer(previewLayer, at: 0)
		videoPreviewLayer = previewLayer
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		videoPreviewLayer.frame = bounds
		shutterSimulation.frame = bounds

	}

	private func setup() {
		shutterSimulation = UIView(frame: bounds)
		shutterSimulation.backgroundColor = .black
		shutterSimulation.alpha = 0
		addSubview(shutterSimulation)
		backgroundColor = .black
	}
}
