//
//  ExposurePhotoVideoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import AVKit

class ExposurePhotoVideoViewController: UIViewController, ManagedObjectContextStackSettable, CameraViewDelegate {
	
	// MARK: View Controller properties and life cycle
	
	var managedObjectContextStack: ManagedObjectContextStack!
	
	@IBOutlet weak var cameraView: PreviewView!
	
	var photoVideo: PhotoVideoCapture!
	
	override func viewDidLoad() {
		// set up video preview and PhotoAudioVideo object
		photoVideo = PhotoVideoCapture(delegate: self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		photoVideo.viewAppeared()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		photoVideo.viewDissapeared()
	}
	
	@IBAction func shortPress(_ sender: UITapGestureRecognizer) {
		
	}
	
	func didTakeImage(image: UIImage) {
		
	}
	
	func didTakeVideo(video: Data) {
		
	}
	
	func didTakeLivePhoto(image: UIImage, video: Data) {
		
	}
		
	func takePhoto() {
			
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case .some("AudioSegue"):
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		case .some("FullViewSegue"):
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		default: break
		}
	}
}



