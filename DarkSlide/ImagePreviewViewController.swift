//
//  ImagePreviewViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 29/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ImagePreviewViewController: UIViewController {

	var highResPhotoWithLivePhotoRef: (UIImage, String?)!
	@IBOutlet weak var imageView: UIImageView!

	override func viewDidLoad() {
		imageView.image = highResPhotoWithLivePhotoRef.0
	}

	@IBAction func tapToPlayLivePhoto(_ sender: Any) {
		print("tap, \(highResPhotoWithLivePhotoRef.1)")
		// if PhotoNote contains a live photo play it by tapping imageview.
		if let livePhotoURL = highResPhotoWithLivePhotoRef.1 {
			let player = AVPlayer(url: PhotoNote.generateLivePhotoPath(livePhotoReferenceNumber: livePhotoURL))
			let playerController = AVPlayerViewController()
			playerController.player = player
			self.present(playerController, animated: true) {
				playerController.player!.play()
			}
		}
	}
	
	@IBAction func doDismiss(_ sender: Any) {
		presentingViewController?.dismiss(animated: true, completion: nil)
	}

}
