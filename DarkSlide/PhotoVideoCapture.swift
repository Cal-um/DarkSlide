//
//  PhotoVideoCapture.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/10/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoVideoCapture: NSObject, AVCaptureFileOutputRecordingDelegate {
	
	

	
	// MARK: Session Management
	
	private enum SessionSetupResult {
		case success
		case notAuthorised
		case configurationFailed
	}
	
	private let session = AVCaptureSession()
	
	private var isSessionRunning = false
	
	private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
	
	private var setupResult: SessionSetupResult = .success
	
	var videoDeviceInput: AVCaptureDeviceInput!
	
	weak var cameraViewDelegate: CameraViewDelegate!
	
	// Call this on the session queue.
	private func configureSession() {
		if setupResult != .success {
			return
		}
		
		session.beginConfiguration()
		
		/*
		We do not create an AVCaptureMovieFileOutput when setting up the session because the
		AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto.
		*/
		
		session.sessionPreset = AVCaptureSessionPresetPhoto
		
		// Add video input
		
		do {
			var defaultVideoDevice: AVCaptureDevice?
			
			// Choose the back dual camera if available, otherwise default to a wide angle camera.
			
			if let dualCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back) {
				defaultVideoDevice = dualCameraDevice
			}
			else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
				// If the back dual camera is not available, default to the back wide angle camera.
				defaultVideoDevice = backCameraDevice
			}
			else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
				// In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
				defaultVideoDevice = frontCameraDevice
			}
			
			let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
			
				if session.canAddInput(videoDeviceInput) {
					session.addInput(videoDeviceInput)
					self.videoDeviceInput = videoDeviceInput
					
					DispatchQueue.main.async {
						
						/*
						Why are we dispatching this to the main queue?
						Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
						can only be manipulated on the main thread.
						Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
						on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
						
						Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
						handled by CameraViewController.viewWillTransition(to:with:).
						*/
						
						let statusBarOrientation = UIApplication.shared.statusBarOrientation
						var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
						if statusBarOrientation != .unknown {
							if let videoOrientation = statusBarOrientation.videoOrientation {
								initialVideoOrientation = videoOrientation
							}
						}
						
						self.cameraViewDelegate.cameraView.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation
					}
				}
				else {
					print("Could not add video device input to the session")
					setupResult = .configurationFailed
					session.commitConfiguration()
					return
				}
			}
			catch {
				print("Could not create video device input: \(error)")
				setupResult = .configurationFailed
				session.commitConfiguration()
				return
		}
		
		// Add audio input.
		do {
			let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
			let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
			
			if session.canAddInput(audioDeviceInput) {
				session.addInput(audioDeviceInput)
			}
			else {
				print("could not add audio device input to the session")
			}
		}
		catch {
			print("could not create audio device input \(error)")
		}
		
		// add photo output
		
		if session.canAddOutput(photoOutput) {
			
			session.addOutput(photoOutput)
			photoOutput.isHighResolutionCaptureEnabled = true
			photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
			livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
		}
		else {
			print("could not add photo output to the session")
			setupResult = .configurationFailed
			session.commitConfiguration()
			return
		}
		
		session.commitConfiguration()
	}
	
	// MARK: Resume iterrupted session
	// use this block in a place where it can notify the user and to restart the session
	
	private func resumeInterupptedSession() {
		sessionQueue.async { [unowned self] in
			/*
			The session might fail to start running, e.g., if a phone or FaceTime call is still
			using audio or video. A failure to start the session running will be communicated via
			a session runtime error notification. To avoid repeatedly failing to start the session
			running, we only try to restart the session running in the session runtime error handler
			if we aren't trying to resume the session running.
			*/
			
			self.session.startRunning()
			self.isSessionRunning = self.session.isRunning
			if !self.isSessionRunning {
				DispatchQueue.main.async { [unowned self] in
					// handle UI with alert controller or similar.
				}
			}
			else {
				DispatchQueue.main.async { [unowned self] in
					// handle UI if session running.
				}
			}
		}
	}
	
	private enum CaptureMode: Int {
		case photo = 0
		case movie = 1
	}
	
	@IBOutlet private weak var captureModeControl: UISegmentedControl!
	
	func toggleCaptureMode() {
		
		if captureModeControl.selectedSegmentIndex == CaptureMode.photo.rawValue {
			
			sessionQueue.async { [unowned self] in
				/*
				Remove the AVCaptureMovieFileOutput from the session because movie recording is
				not supported with AVCaptureSessionPresetPhoto. Additionally, Live Photo
				capture is not supported when an AVCaptureMovieFileOutput is connected to the session.
				*/
				self.session.beginConfiguration()
				self.session.removeOutput(self.movieFileOutput)
				self.session.sessionPreset = AVCaptureSessionPresetPhoto
				self.session.commitConfiguration()
				
				self.movieFileOutput = nil
				
				if self.photoOutput.isLivePhotoCaptureSupported {
					self.photoOutput.isLivePhotoCaptureEnabled = true
				}
			}
		} else if captureModeControl.selectedSegmentIndex == CaptureMode.movie.rawValue {
			sessionQueue.async { [unowned self] in
				let movieFileOutput = AVCaptureMovieFileOutput()
				
				if self.session.canAddOutput(movieFileOutput) {
					self.session.beginConfiguration()
					self.session.addOutput(movieFileOutput)
					self.session.sessionPreset = AVCaptureSessionPresetHigh
					if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
						if connection.isVideoStabilizationSupported {
							connection.preferredVideoStabilizationMode = .auto
						}
					}
					self.session.commitConfiguration()
					
					self.movieFileOutput = movieFileOutput
					}
				}
			}
	}
	
	// MARK: Device Configuration
	
	private let videoDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaTypeVideo, position: .unspecified)!
	
	func changeCamera() {
		// Disable buttons
		sessionQueue.async { [unowned self] in
			let currentVideoDevice = self.videoDeviceInput.device
			let currentPosition = currentVideoDevice!.position
			
			let preferredPosition: AVCaptureDevicePosition
			let preferredDeviceType: AVCaptureDeviceType
			
			switch currentPosition {
			case .unspecified, .front:
				preferredPosition = .back
				preferredDeviceType = .builtInDuoCamera
			case .back:
				preferredPosition = .front
				preferredDeviceType = .builtInWideAngleCamera
			}
			
			let devices = self.videoDeviceDiscoverySession.devices!
			var newVideoDevice: AVCaptureDevice? = nil
			
			// First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
			if let device = devices.filter({ $0.position == preferredPosition && $0.deviceType == preferredDeviceType }).first {
				newVideoDevice = device
			}
			else if let device = devices.filter({ $0.position == preferredPosition }).first {
				newVideoDevice = device
			}
			
			if let videoDevice = newVideoDevice {
				do {
					let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
					
					self.session.beginConfiguration()
					
					// Remove the existing device input first, since using the front and back camera simultaneously is not supported.
					self.session.removeInput(self.videoDeviceInput)
					
					if self.session.canAddInput(videoDeviceInput) {
						NotificationCenter.default.removeObserver(self, name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: currentVideoDevice!)
						
						NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: videoDeviceInput.device)
						
						self.session.addInput(videoDeviceInput)
						self.videoDeviceInput = videoDeviceInput
					}
					else {
						self.session.addInput(self.videoDeviceInput);
					}
					
					if let connection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
						if connection.isVideoStabilizationSupported {
							connection.preferredVideoStabilizationMode = .auto
						}
					}
					
					/*
					Set Live Photo capture enabled if it is supported. When changing cameras, the
					`isLivePhotoCaptureEnabled` property of the AVCapturePhotoOutput gets set to NO when
					a video device is disconnected from the session. After the new video device is
					added to the session, re-enable Live Photo capture on the AVCapturePhotoOutput if it is supported.
					*/
					self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported;
					
					self.session.commitConfiguration()
				}
				catch {
					print("Error occured while creating video device input: \(error)")
				}
				
				//Enable buttons again
			}
		}
	}
	
	private func focus(with focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
		sessionQueue.async { [unowned self] in
			if let device = self.videoDeviceInput.device {
				do {
					try device.lockForConfiguration()
					
					/*
					Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
					Call set(Focus/Exposure)Mode() to apply the new point of interest.
					*/
					if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
						device.focusPointOfInterest = devicePoint
						device.focusMode = focusMode
					}
					
					if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
						device.exposurePointOfInterest = devicePoint
						device.exposureMode = exposureMode
					}
					
					device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
					device.unlockForConfiguration()
				}
				catch {
					print("Could not lock device for configuration: \(error)")
				}
			}
		}
	}

	
	// MARK: Recording movies
	
	private var movieFileOutput: AVCaptureMovieFileOutput? = nil
	
	private var backgroundrecordingID: UIBackgroundTaskIdentifier? = nil
	
	@IBOutlet private weak var recordButton: UIButton!
	
	@IBOutlet private weak var resumeButton: UIButton!
	
	func toggleMovieRecording() {
		guard let movieFileOutput = self.movieFileOutput else { return }
		/*
		Disable the Camera button until recording finishes, and disable
		the Record button until recording starts or finishes.
		
		See the AVCaptureFileOutputRecordingDelegate methods.
		*/
		
		// configure buttons
		
		let videoPreviewLayerOrientation = cameraViewDelegate.cameraView.videoPreviewLayer.connection.videoOrientation
		
		sessionQueue.async { [unowned self] in
			if !movieFileOutput.isRecording {
				if UIDevice.current.isMultitaskingSupported {
					/*
					Setup background task.
					This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
					callback is not received until AVCam returns to the foreground unless you request background execution time.
					This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
					To conclude this background execution, endBackgroundTask(_:) is called in
					`capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
					*/
					
					self.backgroundrecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
				}
				
				// Update the orientation on the movie file output video connection before starting recording before starting recording.
				
				let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
				movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation
				
				// Start recording to a temporary file 
				
				let outputFileName = NSUUID().uuidString
				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
				movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
			}
			else {
				movieFileOutput.stopRecording()
			}
		}
	}
	
	func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
		/*
		Note that currentBackgroundRecordingID is used to end the background task
		associated with this recording. This allows a new recording to be started,
		associated with a new UIBackgroundTaskIdentifier, once the movie file output's
		`isRecording` property is back to false — which happens sometime after this method
		returns.
		
		Note: Since we use a unique file path for each recording, a new recording will
		not overwrite a recording currently being saved.
		*/
		
		func cleanUp() {
			let path = outputFileURL.path
			
			if FileManager.default.fileExists(atPath: path) {
				do {
					try FileManager.default.removeItem(atPath: path)
				}
				catch {
					print("Could not remove file at url: \(outputFileURL)")
				}
			}
			
			if let currentBackgroundRecordingID = backgroundrecordingID {
				backgroundrecordingID = UIBackgroundTaskInvalid
				
				if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
					UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
				}
			}
		}
		
		var success = true
		
		if error != nil {
			print("Movie file finishing error \(error)")
				success = (((error as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
		}
		
		if success {
			// save to preffered location and cleanup
		}
		
		// Enable the Camera and Record buttons to let the user switch camera and start another recording on main queue.
		
		
	}
	
	// Enable the Camera and Record buttons to let the user switch camera and start another recording.
	
	// code here
	
	
	
	
	// MARK: KVO and Notifications
	
	
	private var sessionRunningObserveContext = 0
	
	private func addObservers() {
		session.addObserver(self, forKeyPath: "running", options: .new, context: &sessionRunningObserveContext)
		
		NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: videoDeviceInput.device)
		NotificationCenter.default.addObserver(self, selector: #selector( sessionRuntimeError), name: Notification.Name("AVCaptureSessionRuntimeErrorNotification"), object: session)
		
		/*
		A session can only run when the app is full screen. It will be interrupted
		in a multi-app layout, introduced in iOS 9, see also the documentation of
		AVCaptureSessionInterruptionReason. Add observers to handle these session
		interruptions and show a preview is paused message. See the documentation
		of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
		*/
		
		NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: Notification.Name("AVCaptureSessionWasInterruptedNotification"), object: session)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: Notification.Name("AVCaptureSessionInterruptionEndedNotification"), object: session)
	}
	
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		session.removeObserver(self, forKeyPath: "running", context: &sessionRunningObserveContext)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context == &sessionRunningObserveContext {
			let newValue = change?[.newKey] as AnyObject?
			guard let isSessionRunning = newValue?.boolValue else { return }
			let isLivePhotoCaptureSupported = photoOutput.isLivePhotoCaptureSupported
			let isLivePhotoCaptureEnables = photoOutput.isLivePhotoCaptureEnabled
			
			DispatchQueue.main.async { [unowned self] in
				// Only enable the ability to change camera if the device has more than one camera.
//				self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount() > 1
//				self.recordButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
//				self.photoButton.isEnabled = isSessionRunning
//				self.captureModeControl.isEnabled = isSessionRunning
//				self.livePhotoModeButton.isEnabled = isSessionRunning && isLivePhotoCaptureEnabled
//				self.livePhotoModeButton.isHidden = !(isSessionRunning && isLivePhotoCaptureSupported)
			}
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	func subjectAreaDidChange(notification: NSNotification) {
		let devicePoint = CGPoint(x: 0.5, y: 0.5)
		focus(with: .autoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectChange: false)
	}
	
	func sessionErrorRuntimeError(notification: NSNotification) {
		guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
			return
		}
		
		let error = AVError(_nsError: errorValue)
		print("Capture session runtime error \(error)")
		/*
		Automatically try to restart the session running if media services were
		reset and the last start running succeeded. Otherwise, enable the user
		to try to resume the session running.
		*/
		
		if error.code == .mediaServicesWereReset {
			sessionQueue.async { [unowned self] in
				if self.isSessionRunning {
					self.session.startRunning()
					self.isSessionRunning = self.session.isRunning
				}
				else {
					DispatchQueue.main.async { [unowned self] in
				//		self.resumeButton.isHidden = false
					}
				}
			}
		}
		else {
			//resumeButton.isHidden = false
		}
	}
	func sessionWasInterrupted(notification: NSNotification) {
		/*
		In some scenarios we want to enable the user to resume the session running.
		For example, if music playback is initiated via control center while
		using AVCam, then the user can let AVCam resume
		the session running, which will stop music playback. Note that stopping
		music playback in control center will not automatically resume the session
		running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
		*/
		if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?, let reasonIntegerValue = userInfoValue.integerValue, let reason = AVCaptureSessionInterruptionReason(rawValue: reasonIntegerValue) {
			print("Capture session was interrupted with reason \(reason)")
			
			var showResumeButton = false
			
			if reason == AVCaptureSessionInterruptionReason.audioDeviceInUseByAnotherClient || reason == AVCaptureSessionInterruptionReason.videoDeviceInUseByAnotherClient {
				showResumeButton = true
			}
			else if reason == AVCaptureSessionInterruptionReason.videoDeviceNotAvailableWithMultipleForegroundApps {
				// Simply fade-in a label to inform the user that the camera is unavailable.
				//cameraUnavailableLabel.alpha = 0
			//	cameraUnavailableLabel.isHidden = false
			//	UIView.animate(withDuration: 0.25) { [unowned self] in
			//		self.cameraUnavailableLabel.alpha = 1
			//	}
			}
			
			if showResumeButton {
				// Simply fade-in a button to enable the user to try to resume the session running.
				//resumeButton.alpha = 0
				//resumeButton.isHidden = false
			//	UIView.animate(withDuration: 0.25) { [unowned self] in
			//		self.resumeButton.alpha = 1
//	}
			}
		}
	}
	
	func sessionInterruptionEnded(notification: NSNotification) {
		print("Capture session interruption ended")
		
//		if !resumeButton.isHidden {
//			UIView.animate(withDuration: 0.25,
//			               animations: { [unowned self] in
//											self.resumeButton.alpha = 0
//				}, completion: { [unowned self] finished in
//					self.resumeButton.isHidden = true
//				}
//			)
//		}
////		if !cameraUnavailableLabel.isHidden {
////			UIView.animate(withDuration: 0.25,
////			               animations: { [unowned self] in
////											self.cameraUnavailableLabel.alpha = 0
////				}, completion: { [unowned self] finished in
////					self.cameraUnavailableLabel.isHidden = true
////				}
////			)
//	//	}
//	}
	}


	// MARK: Capturing photos.
	
	private let photoOutput = AVCapturePhotoOutput()
	private var inProgressPhotoCaptureDelegates = [Int64 : PhotoCaptureDelegate]()
	
	func capturePhoto() {
		/*
		Retrieve the video preview layer's video orientation on the main queue before
		entering the session queue. We do this to ensure UI elements are accessed on
		the main thread and session configuration is done on the session queue.
		*/
		let videoPreviewLayerOrientation = cameraViewDelegate.cameraView.videoPreviewLayer.connection.videoOrientation
		
		sessionQueue.async {
			// update the photo output's connection to match the video orientation of the video preview layer.
			
			if let photoOutputConnection = self.photoOutput.connection(withMediaType: AVMediaTypeVideo) {
				photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
			}
			
			// capture a jpeg photo with flash set to auto and high resolution enabled.
			let photoSettings = AVCapturePhotoSettings()
			photoSettings.flashMode = .auto
			photoSettings.isHighResolutionPhotoEnabled = true
			if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
				photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
			}
		
			// Live Photo capture is not supported in movie mode.
			if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported {
				let livePhotoMovieFileName = NSUUID().uuidString
				let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
				photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
			}
			
			// Use a separate object for the photo capture delegate to isolate each capture life cycle.
			let photoCaptureDelegate = PhotoCaptureDelegate(with: photoSettings, willCapturePhotoAnimation: {
				  DispatchQueue.main.async { [unowned self] in
				    self.cameraViewDelegate.cameraView.videoPreviewLayer.opacity = 0
				  	UIView.animate(withDuration: 0.25) { [unowned self] in
					  	self.cameraViewDelegate.cameraView.videoPreviewLayer.opacity = 1
					  }
				  }
				}, capturingLivePhoto: { capturing in
					/*
					Because Live Photo captures can overlap, we need to keep track of the
					number of in progress Live Photo captures to ensure that the
					Live Photo label stays visible during these captures.
					*/
					
					self.sessionQueue.async { [unowned self] in
						if capturing {
							self.inProgressLivePhotoCapturesCount += 1
						}
							else {
								self.inProgressLivePhotoCapturesCount -= 1
							}
						
						let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
						DispatchQueue.main.async { [unowned self] in
							if inProgressLivePhotoCapturesCount > 0 {
							//	self.capturingLivePhotoLabel.isHidden = false
							}
							else if inProgressLivePhotoCapturesCount == 0 {
								//self.capturingLivePhotoLabel.isHidden = true
							}
							else {
								print("Error: In progress live photo capture count is less than 0");
							}
						}
					}
				}	, completed: { [unowned self] photoCaptureDelegate in
					// When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
					self.sessionQueue.async { [unowned self] in
						self.inProgressPhotoCaptureDelegates[photoCaptureDelegate.requestedPhotoSettings.uniqueID] = nil
					}
				}
			)
			
			/*
			The Photo Output keeps a weak reference to the photo capture delegate so
			we store it in an array to maintain a strong reference to this object
			until the capture is completed.
			*/
			
			self.inProgressPhotoCaptureDelegates[photoCaptureDelegate.requestedPhotoSettings.uniqueID] = photoCaptureDelegate
			self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
		}
	}
	private enum LivePhotoMode {
		case on
		case off
	}
	
	private var inProgressLivePhotoCapturesCount = 0
	private var livePhotoMode: LivePhotoMode = .off
	
	func toggleLivePhotoMode() {
		
		sessionQueue.async { [unowned self] in
			self.livePhotoMode = (self.livePhotoMode == .on) ? .off : .on
			let livePhotoMode = self.livePhotoMode
			
			DispatchQueue.main.async { [unowned self] in
				// set button for live photo on.
			}
		}
	}
	
}

extension UIInterfaceOrientation {
	var videoOrientation: AVCaptureVideoOrientation? {
		switch self {
		case .portrait: return .portrait
		case .portraitUpsideDown: return .portraitUpsideDown
		case .landscapeLeft: return .landscapeLeft
		case .landscapeRight: return .landscapeRight
		default: return nil
		}
	}
}

extension UIDeviceOrientation {
	var videoOrientation: AVCaptureVideoOrientation? {
		switch self {
		case .portrait: return .portrait
		case .portraitUpsideDown: return .portraitUpsideDown
		case .landscapeLeft: return .landscapeRight
		case .landscapeRight: return .landscapeLeft
		default: return nil
		}
	}
}

extension AVCaptureDeviceDiscoverySession {
	func uniqueDevicePositionsCount() -> Int {
		var uniqueDevicePositions = [AVCaptureDevicePosition]()
		
		for device in devices {
			if !uniqueDevicePositions.contains(device.position) {
				uniqueDevicePositions.append(device.position)
			}
		}
		
		return uniqueDevicePositions.count
	}
}