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

class ExposurePhotoVideoViewController: UIViewController, ExposureAudioNoteViewControllerDelegate {

	// MARK: View Controller properties and life cycle

	weak var cameraOutputDelegate: CameraOutputDelegate!
	weak var audioOutputDelegate: AudioNoteDelegate!
	var disableSessionStart: Bool = false

	@IBOutlet weak var cameraUnavailableLabel: UILabel!
	@IBOutlet weak var resumeSessionButton: UIButton!

	// MARK: Delegate properies. Used to observe state of photoVideo.

	var observeLivePhotoModeSelected: LivePhotoMode = .off
	var observeFlashConfiguration: AVCaptureFlashMode = .auto
	var observeCaptureMode: CaptureMode = .photo
	var observeCameraFacing: CameraFacing = .front
	var observeLivePhotoPlaying: Bool = false {
		didSet {
			DispatchQueue.main.async {
				self.livePhotoIndicator.isHidden = !self.observeLivePhotoPlaying
			}
		}
	}
	var observeMovieRecording: Bool = false

	@IBOutlet weak var cameraView: PreviewView!

	var photoVideo: PhotoVideoCapture!

	override func viewDidLoad() {
		// set up video preview and PhotoAudioVideo object
		photoVideo = PhotoVideoCapture(cameraViewDelegate: self, cameraOutputDelegate: cameraOutputDelegate)
		// The default is livePhoto off so this ensures live photo is on for capable devices
		photoVideo.toggleLivePhotoMode()
		configureButton()
	}

	override func viewDidAppear(_ animated: Bool) {
		if !disableSessionStart {
			photoVideo.viewAppeared()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		photoVideo.viewDissapeared()
	}

	@IBOutlet weak var takeExposureButton: UIButton!

	@IBOutlet weak var livePhotoIndicator: UIView!

	@IBAction func resumeSession(_ sender: Any) {
		photoVideo.resumeInterupptedSession()
	}

	@IBAction func tapExposureButton(_ sender: Any) {
		photoVideo.capturePhoto()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case .some("AudioSegue"):
			guard let vc = segue.destination as? ExposureAudioNoteViewController else { fatalError("wrong view controller type") }
			vc.audioNoteDelegate = audioOutputDelegate
			vc.delegate = self
		case .some("FullViewSegue"):
			guard let vc = segue.destination as? FullScreenCameraViewController else { fatalError("wrong view controller type") }
			vc.cameraOutputDelegate = cameraOutputDelegate
		default: break
		}
	}

	deinit {
		print("DEINIT ExposurePhotoVideoViewController")
	}
}

extension ExposurePhotoVideoViewController: CameraViewDelegate {

	func disableButtons() {
		takeExposureButton.isEnabled = false
	}

	func configureButton() {
		livePhotoIndicator.layer.cornerRadius = livePhotoIndicator.bounds.width / 2
		livePhotoIndicator.clipsToBounds = true
		livePhotoIndicator.layer.masksToBounds = true
		livePhotoIndicator.isHidden = true
		livePhotoIndicator.backgroundColor = .orange
	}

	func enableButtons(buttonconfiguration: ButtonConfiguration) {
			takeExposureButton.isEnabled = true
	}

	func unableToResumeUninteruptedSessionAlert() {
		self.present(unableToResumeUninteruptedSessionAlertController(), animated: true, completion: nil)
	}

	func alertActionNoCameraPermission() {
		self.present(alertActionNoCameraPermissionAlertController(), animated: true, completion: nil)
	}

	func hideResumeButton(hide: Bool) {
		if hide {
			resumeSessionButton.isHidden = true
		} else {
			resumeSessionButton.isHidden = false
		}
	}

	func hideCameraUnavailableLabel(hide: Bool) {
		if hide {
			cameraUnavailableLabel.isHidden = true
		} else {
			cameraUnavailableLabel.isHidden = false
		}
	}
}

extension ExposurePhotoVideoViewController: AVAudioRecorderDelegate {}
