//
//  CameraOutputDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 28/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol CameraOutputDelegate: class {
	func didTakePhoto(jpeg: Data, thumbnail: Data, livePhoto: String?)
	func didTakeVideo(videoReferenceNumber: String)
}
