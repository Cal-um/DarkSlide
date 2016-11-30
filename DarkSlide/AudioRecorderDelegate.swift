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

	func disableRecordButton()
	func enableRecordButton()
	func alertActionNoMicrophonePermission()
}

protocol AudioNoteDelegate: class {

	func didSaveAudioRecording(fileReferenceNumber: String)
}
