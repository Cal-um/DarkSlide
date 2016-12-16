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

class ExposureAudioNoteViewController: UIViewController {

	weak var audioNoteDelegate: AudioNoteDelegate!
	var audioRecorder: AudioRecorder!
	var audioReferenceNumber: String?

	deinit {
		print("ExposureAudioViewController DEINIT")
	}

	@IBAction func dismissViewController(_ sender: Any) {
		presentingViewController!.dismiss(animated: true, completion: nil)
	}

	@IBOutlet weak var audioRecordButton: UIButton!

	override func viewDidLoad() {
		audioRecorder = AudioRecorder(delegate: self)
		addObservers()
		audioRecordButton.setTitle("Record Audio", for: .normal)
	}

	override func viewDidAppear(_ animated: Bool) {
		audioRecorder.viewAppeared()
	}

	@IBAction func toggleAudioRecording(_ sender: Any) {
		audioRecorder.toggleAudioRecording()
	}

	func addObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.exitViewController), name: Notification.Name(NotificationIdentifiers.PhotoVideo.WillClosePreviewView), object: nil)
	}

	func exitViewController() {
		
		dismiss(animated: true, completion: nil)
	}

	var player: AudioPlayer!
}

extension ExposureAudioNoteViewController: AudioRecorderDelegate, SpeechToTextDelegate {

	func disableRecordButton() {
		audioRecordButton.isEnabled = false
	}

	func enableRecordButton() {
		audioRecordButton.isEnabled = true
	}
	
	func didBeginRecording() {
		print("didBeginRecording")
		DispatchQueue.main.async {
			self.audioRecordButton.setTitle("Stop Recording", for: .normal)
		}
	}
	
	func didEndRecording() {
		print("didEndRecording")
		DispatchQueue.main.async {
			self.audioRecordButton.setTitle("Record Audio", for: .normal)
		}
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
		guard let reference = audioReferenceNumber, flag else { return }
			audioNoteDelegate.didSaveAudioRecording(fileReferenceNumber: reference)
			print("\(recorder.url.path) RECORDER PATH")
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

	func alertUserOfSpeechRecognitionAllowance() {
		self.present(alertUserOfSpeechRecognitionAllowanceAlertController(), animated: true, completion: nil)
	}
}
