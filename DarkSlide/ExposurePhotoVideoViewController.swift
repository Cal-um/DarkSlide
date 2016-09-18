//
//  ExposurePhoto+VideoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class ExposurePhotoVideoViewController: UIViewController, CameraViewDelegate {
	
	@IBOutlet weak var cameraView: UIView!
	
	override func viewDidLoad() {
		PhotoAudioVideo(cameraViewDelegate: self)
	}
}

