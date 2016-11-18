//
//  ExposureAudioViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 19/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit

class ExposureAudioNoteViewController: UIViewController, ManagedObjectContextStackSettable {
	
	var managedObjectContextStack: ManagedObjectContextStack!
	var audioRecorder: AudioRecorder!
	
	@IBAction func dismissViewController(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBOutlet weak var audioRecordButton: UIButton!
	
	override func viewDidLoad() {
		audioRecorder = AudioRecorder(delegate: self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		audioRecorder.viewAppeared()
	}
	
	@IBAction func toggleAudioRecording(_ sender: Any) {
		audioRecorder.toggleAudioRecording()
	}
	
	var player: AudioPlayer!
}

	
extension ExposureAudioNoteViewController: AudioRecorderDelegate {
	
	func disableRecordButton() {
		audioRecordButton.isEnabled = false
	}
	
	func enableRecordButton() {
		audioRecordButton.isEnabled = true
	}
	
	func alertActionNoMicrophonePermission() {
		let message = "Dark Slide doesn't have permission to use the Microphone, please change privacy settings"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { action in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
		}))
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if flag {
			print(recorder.url)
			// Play sound with AudioPlayer class
			//player = AudioPlayer()
			//player.playSoundFile(atPath: recorder.url)
			
			// Play sounds with AVPlayer
			
			let player = AVPlayer(url: recorder.url)
			let playerController = AVPlayerViewController()
			playerController.player = player
			self.present(playerController, animated: true) {
				playerController.player!.play()
				
			}
		}
	}
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		if let error = error {
			print(error)
		}
		recorder.stop()
		recorder.deleteRecording()
		alertErrorRecordingMessage()
	}
	
	func alertErrorRecordingMessage() {
		let message = "Error recoding audio note, please try again"
		let alertController = UIAlertController(title: "Dark Slide", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
}


