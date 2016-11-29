//
//  AudioRecorder.swift
//  DarkSlide
//
//  Created by Calum Harris on 13/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorder: NSObject {

	weak var delegate: AudioRecorderDelegate!

	private var setupResult = true

	private let audioSession = AVAudioSession.sharedInstance()

	private var audioRecorder: AVAudioRecorder!

	private let audioQueue = DispatchQueue(label: "audio queue", attributes: [], target: nil)

	init(delegate: AudioRecorderDelegate) {
		super.init()
		self.delegate = delegate
		initialLoad()
	}

	private func initialLoad() {

		delegate.disableRecordButton()

		switch audioSession.recordPermission() {

		case AVAudioSessionRecordPermission.undetermined:
			audioQueue.suspend()
			audioSession.requestRecordPermission { [unowned self] permissionGranted in
				if !permissionGranted {
					self.setupResult = false
				}
				self.audioQueue.resume()
			}

		case AVAudioSessionRecordPermission.granted:
			break

		default:
			// user already denied microphone use.
			self.setupResult = false
		}
	}

	func viewAppeared() {

		if !setupResult {
			self.delegate.alertActionNoMicrophonePermission()
		} else {
			self.delegate.enableRecordButton()
		}
	}
	
	func viewDissapeared() {
		if audioRecorder.isRecording {
			audioRecorder.stop()
		}
	}

	private func beginRecording() {

		audioQueue.async { [unowned self] in

			let randomReferenceNumber = AudioNote.randomReferenceNumber
			let filePath = AudioNote.generateAudioPath(audioReferenceNumber: randomReferenceNumber)

			do {
				try self.audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
			} catch {
				fatalError("error setting up audio recorder")
			}

			do {
				try self.audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
				} catch {
				fatalError("Error recording audio file ERROR:\(error)")
			}
			
			self.audioRecorder.delegate = self.delegate
			self.audioRecorder.isMeteringEnabled = true
			self.audioRecorder.prepareToRecord()
			self.audioRecorder.record()
		}
	}

	func toggleAudioRecording() {

		audioQueue.async { [unowned self] in
			if self.audioRecorder != nil, self.audioRecorder.isRecording {
				self.audioRecorder.stop()
			} else {
				guard self.setupResult else { fatalError("incorrect button config") }
				self.beginRecording()
			}
		}
	}
}
