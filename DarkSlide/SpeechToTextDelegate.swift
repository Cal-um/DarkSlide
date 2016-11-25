//
//  SpeechToTextDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol SpeechToTextDelegate {

	func alertUserOfSpeechRecognitionAllowance()

	//func didProcessAudioFileToText()

}

extension SpeechToTextDelegate {

	func alertUserOfSpeechRecognitionAllowanceAlertController() -> UIAlertController {
		let message = "Dark Slide doesn't have permission to use Speech Recognition, please change privacy settings"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { action in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
		}))
		return alertController
	}

}
