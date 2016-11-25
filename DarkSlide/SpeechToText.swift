//
//  SpeechToText.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import Speech

class SpeechToText: NSObject {

	var delegate: SpeechToTextDelegate!

	init(delegate: SpeechToTextDelegate) {
		super.init()
		self.delegate = delegate
		self.startUp()
	}

	private var authorisationStatus: SFSpeechRecognizerAuthorizationStatus = .authorized

	private func startUp() {

		switch SFSpeechRecognizer.authorizationStatus() {
		case .authorized:
			// the user has previously granted access to Speech Recogniser.
			break
		case .notDetermined:
			SFSpeechRecognizer.requestAuthorization { requestResult in
				self.authorisationStatus = requestResult
			}
		case .denied, .restricted:
			delegate.alertUserOfSpeechRecognitionAllowance()
			authorisationStatus = .denied
		}
	}

	func processAudioFile(url: URL) {

		if authorisationStatus == .authorized {
			requestSpeechRecognition(url: url, completion: { result in
				print(result)
			})
		} else {
			print("Not Authorised")
		}
	}

	private func requestSpeechRecognition(url: URL, completion: @escaping (String) -> ()) {

		guard let myRecognizer = SFSpeechRecognizer() else {
			// SR not available for this locale
			completion("error SR not available for this locale")
			return
		}

		if !myRecognizer.isAvailable {
			completion("Speech recognizer not available at the moment")
			return
		}

		let request = SFSpeechURLRecognitionRequest(url: url)

		myRecognizer.recognitionTask(with: request, resultHandler: { result, error in

			guard let result = result else { print(error!) ; return }

			if result.isFinal {
				completion(result.bestTranscription.formattedString)
			}
		})
	}

}
