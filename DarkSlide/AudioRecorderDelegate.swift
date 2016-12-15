//
//  AudioRecorderDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 13/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecorderDelegate: class, AVAudioRecorderDelegate {

	var audioReferenceNumber: String? { get set }
	func disableRecordButton()
	func enableRecordButton()
	func alertActionNoMicrophonePermission()
	func didBeginRecording()
	func didEndRecording()
}

protocol AudioNoteDelegate: class {

	func didSaveAudioRecording(fileReferenceNumber: String)
}
