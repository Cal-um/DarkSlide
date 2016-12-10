//
//  PhotoVideoCapture.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/10/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

// swiftlint:disable type_body_length
// swiftlint:disable file_length

import UIKit
import AVFoundation

class PhotoVideoCapture: NSObject, AVCaptureFileOutputRecordingDelegate, CameraUtils {

	// MARK: Init

	weak var cameraViewDelegate: CameraViewDelegate!
	weak var cameraOutputDelegate: CameraOutputDelegate!

	init(cameraViewDelegate: CameraViewDelegate, cameraOutputDelegate: CameraOutputDelegate) {
		self.cameraViewDelegate = cameraViewDelegate
		self.cameraOutputDelegate = cameraOutputDelegate
		super.init()
		initialLoad()
	}

	func initialLoad() {

		// Disable UI. The UI is enabled if and only if the session starts running.
		cameraViewDelegate.disableButtons()
		// Set up the video preview view.
		cameraViewDelegate.cameraView.setupForPreviewLayer(previewLayer: createPreviewLayer())

		/*
		Check video authorization status. Video access is required and audio
		access is optional. If audio access is denied, audio is not recorded
		during movie recording.
		*/

		switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
		case .authorized:
			// the user has previously granted access to the camera
			break

		case .notDetermined:
			/*
			The user has not yet been presented with the option to grant
			video acswitcess. We suspend the session queue to delay session
			setup until the access request has completed.
			
			Note that audio access will be implicitly requested when we
			create an AVCaptureDeviceInput for audio during session setup.
			*/

			sessionQueue.suspend()
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
				if !granted {
					self.setupResult = .notAuthorised
				}
				self.sessionQueue.resume()
				})
		default:
			// the user has previously denied access/
			setupResult = .notAuthorised
		}

		/*
		Setup the capture session.
		In general it is not safe to mutate an AVCaptureSession or any of its
		inputs, outputs, or connections from multiple threads at the same time.
		
		Why not do all of this on the main queue?
		Because AVCaptureSession.startRunning() is a blocking call which can
		take a long time. We dispatch session setup to the sessionQueue so
		that the main queue isn't blocked, which keeps the UI responsive.
		*/
		sessionQueue.async { [unowned self] in
			self.configureSession()
		}
	}

	func createPreviewLayer() -> AVCaptureVideoPreviewLayer {
		return AVCaptureVideoPreviewLayer(session: session)
	}

	func viewAppeared() {

		sessionQueue.async { [unowned self] in

			switch self.setupResult {
			case .success:
				// Only setup observers and start the session running if setup succeeded.
				self.addObservers()
				self.session.startRunning()
				self.isSessionRunning = self.session.isRunning
				print("startUp")
			case .notAuthorised:
				DispatchQueue.main.async { [unowned self] in
					self.cameraViewDelegate.alertActionNoCameraPermission()
				}
			case .configurationFailed:
				print("configuration failed")
			}
		}
	}

	func viewDissapeared() {

		sessionQueue.async { [unowned self] in
			if self.setupResult == .success {
				self.session.stopRunning()
				self.isSessionRunning = self.session.isRunning
				self.removeObservers()
				print("shutDown")
			}
		}
	}

	// MARK: Session Management

	private enum SessionSetupResult {
		case success
		case notAuthorised
		case configurationFailed
	}

	private var session = AVCaptureSession()

	private var isSessionRunning = false

	private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)

	private var setupResult: SessionSetupResult = .success

	var videoDeviceInput: AVCaptureDeviceInput!

	// Call this on the session queue.
	private func configureSession() {

		if setupResult != .success {
			print("moot")
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
			} else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
				// If the back dual camera is not available, default to the back wide angle camera.
				defaultVideoDevice = backCameraDevice
			} else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
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
				} else {
					print("Could not add video device input to the session")
					setupResult = .configurationFailed
					session.commitConfiguration()
					return
				}
			} catch {
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
			} else {
				print("could not add audio device input to the session")
			}
		} catch {
			print("could not create audio device input \(error)")
		}

		// add photo output

		if session.canAddOutput(photoOutput) {

			session.addOutput(photoOutput)
			photoOutput.isHighResolutionCaptureEnabled = true
			photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
		} else {
			print("could not add photo output to the session")
			setupResult = .configurationFailed
			session.commitConfiguration()
			return
		}

		session.commitConfiguration()
	}

	// MARK: Resume iterrupted session
	// use this block in a place where it can notify the user and to restart the session

	func resumeInterupptedSession() {
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
					self.cameraViewDelegate.alertActionNoCameraPermission()
				}
			} else {
				DispatchQueue.main.async { [unowned self] in
					self.cameraViewDelegate.hideResumeButton(hide: true)
				}
			}
		}
	}

	var photoOrMovieCaptureModeControl: CaptureMode = .photo

	func toggleCaptureMode() {

		photoOrMovieCaptureModeControl = (photoOrMovieCaptureModeControl == .photo) ? .movie : .photo

		if photoOrMovieCaptureModeControl == CaptureMode.photo {

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

				DispatchQueue.main.async { [unowned self] in
					self.cameraViewDelegate.observeCaptureMode = .photo
				}
			}
		} else if photoOrMovieCaptureModeControl == CaptureMode.movie {
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

					DispatchQueue.main.async { [unowned self] in
						self.cameraViewDelegate.observeCaptureMode = .movie
					}
				}
			}
	}

	// MARK: Device Configuration

	private let videoDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaTypeVideo, position: .unspecified)!

	func changeCamera() {

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
			} else if let device = devices.filter({ $0.position == preferredPosition }).first {
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
					} else {
						self.session.addInput(self.videoDeviceInput)
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
					self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported

					self.session.commitConfiguration()

					DispatchQueue.main.async { [unowned self] in
						if let videoDevice = newVideoDevice {
							if videoDevice.position == .back || videoDevice.position == .unspecified {
								self.cameraViewDelegate.observeCameraFacing = .back
							} else {
								self.cameraViewDelegate.observeCameraFacing = .front
							}
						}
					}
				} catch {
					print("Error occured while creating video device input: \(error)")
				}
			}
		}
	}

	// MARK: Capture device zoom

	var lastZoomFactor: CGFloat = 0.0

	func zoom(zoomFactorFromPinchGesture factor: CGFloat) {

		let scaledFactor = factor * 0.02

		guard let device = videoDeviceInput.device else { print("Device not found") ; return }
		do {
			try device.lockForConfiguration()
			defer {device.unlockForConfiguration()}
			print("Max zoom for device:\(device.activeFormat.videoMaxZoomFactor) Current Zoom factor:\(device.videoZoomFactor)")

			device.videoZoomFactor = calculateZoomResult(gestureFactor: scaledFactor, lastZoomFactor: lastZoomFactor, currentVideoZoomFactor: device.videoZoomFactor, maxZoomFactor: 6.00)
		} catch {
			print("Error:\(error)")
		}
		lastZoomFactor = scaledFactor
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
				} catch {
					print("Could not lock device for configuration: \(error)")
				}
			}
		}
	}

	// MARK: Recording movies

	private(set) var movieFileOutput: AVCaptureMovieFileOutput? = nil

	private var backgroundrecordingID: UIBackgroundTaskIdentifier? = nil

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
			} else {
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
				} catch {
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

			let referenceNumber = MovieNote.randomReferenceNumber

			do {
			let movie = try Data(contentsOf: outputFileURL)
			print(MovieNote.generateMoviePath(movieReferenceNumber: referenceNumber))
			try movie.write(to: MovieNote.generateMoviePath(movieReferenceNumber: referenceNumber))

			cameraOutputDelegate.didTakeVideo(videoReferenceNumber: referenceNumber)
			} catch {
				print("Error saving movie ERROR:\(error)")
				cleanUp()
				return
			}
		} else {
			cleanUp()
		}

		//TODO:
		// Enable and disable the Camera and Record buttons to let the user switch camera and start another recording on main queue.
	}

	// MARK: KVO and Notifications

	private var sessionRunningObserveContext = 0

	private func addObservers() {
		session.addObserver(self, forKeyPath: "running", options: .new, context: &sessionRunningObserveContext)

		NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: videoDeviceInput.device)
		NotificationCenter.default.addObserver(self, selector: #selector( sessionErrorRuntimeError), name: Notification.Name("AVCaptureSessionRuntimeErrorNotification"), object: session)

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
			let isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureEnabled
			let doesDeviceHaveMoreThanOneCamera = self.videoDeviceDiscoverySession.uniqueDevicePositionsCount() > 1

			DispatchQueue.main.async { [unowned self] in
				// Only enable the ability to change camera if the device has more than one camera.
				guard isSessionRunning else { return }
				let livePhotoEnabledAndSupported = isLivePhotoCaptureEnabled && isLivePhotoCaptureSupported

				self.cameraViewDelegate.enableButtons(buttonconfiguration: self.buttonConfigForObserver(isLivePhotoEnabledAndSupported: livePhotoEnabledAndSupported, doesDeviceHaveMoreThanOneCamera: doesDeviceHaveMoreThanOneCamera))
			}
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}

	func subjectAreaDidChange(notification: NSNotification) {
		let devicePoint = CGPoint(x: 0.5, y: 0.5)
		focus(with: .autoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
	}

	func sessionErrorRuntimeError(notification: NSNotification) {
		guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
			return
		}

		print(errorValue)

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
				} else {
					DispatchQueue.main.async { [unowned self] in
						self.cameraViewDelegate.hideResumeButton(hide: false)
					}
				}
			}
		} else {
			DispatchQueue.main.async { [unowned self] in
				self.cameraViewDelegate.hideResumeButton(hide: false)
			}
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
			} else if reason == AVCaptureSessionInterruptionReason.videoDeviceNotAvailableWithMultipleForegroundApps {
				DispatchQueue.main.async { [unowned self] in
					self.cameraViewDelegate.hideCameraUnavailableLabel(hide: false)
				}
			}

			if showResumeButton {
				DispatchQueue.main.async { [unowned self] in
					self.cameraViewDelegate.hideResumeButton(hide: false)
				}
			}
		}
	}

	func sessionInterruptionEnded(notification: NSNotification) {
		print("Capture session interruption ended")

		DispatchQueue.main.async { [unowned self] in
			self.cameraViewDelegate.hideResumeButton(hide: true)
			self.cameraViewDelegate.hideCameraUnavailableLabel(hide: true)
		}
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

		sessionQueue.async { [unowned self] in
			// update the photo output's connection to match the video orientation of the video preview layer.

			if let photoOutputConnection = self.photoOutput.connection(withMediaType: AVMediaTypeVideo) {
				photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
				print("VIDEO ORIENTATION \(videoPreviewLayerOrientation.rawValue)")
			}

			func configPhotoSettings(flashMode: AVCaptureFlashMode) -> AVCapturePhotoSettings {

				let photoSettings = AVCapturePhotoSettings()
				photoSettings.isHighResolutionPhotoEnabled = false
				if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
					photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
				}

				guard self.photoOutput.supportedFlashModes.contains(NSNumber(value: flashMode.rawValue)) else {
					photoSettings.flashMode = .off
					return photoSettings
				}

				switch flashMode {
				case .on: photoSettings.flashMode = .on
				case .off: photoSettings.flashMode = .off
				case .auto: photoSettings.flashMode = .auto
				}

				return photoSettings
			}

			// capture a jpeg photo with flash set to required setting and high resolution enabled.
			let photoSettings = configPhotoSettings(flashMode: self.flashMode)
			// Live Photo capture is not supported in movie mode.
			if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported {
				let livePhotoMovieFileName = NSUUID().uuidString
				let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
				photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
			}

			// Use a separate object for the photo capture delegate to isolate each capture life cycle.
			let photoCaptureDelegate = PhotoCaptureDelegate(with: photoSettings, cameraViewDelegate: self.cameraViewDelegate, cameraOutputDelegate: self.cameraOutputDelegate, willCapturePhotoAnimation: {
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
						} else {
								self.inProgressLivePhotoCapturesCount -= 1
							}

//						let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
//						DispatchQueue.main.async { [unowned self] in
//							if inProgressLivePhotoCapturesCount > 0 {
//							//	self.capturingLivePhotoLabel.isHidden = false
//							} else if inProgressLivePhotoCapturesCount == 0 {
//								//self.capturingLivePhotoLabel.isHidden = true
//							} else {
//								print("Error: In progress live photo capture count is less than 0")
//							}
//						}
					}
				}, completed: { [unowned self] photoCaptureDelegate in
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

	private var flashMode: AVCaptureFlashMode = .auto

	func toggleFlashMode() {
		switch self.flashMode {
		case .auto: flashMode = .on
		case .on: flashMode = .off
		case .off: flashMode = .auto
		}

		DispatchQueue.main.async { [unowned self] in
			self.cameraViewDelegate.observeFlashConfiguration = self.flashMode
		}
	}

	private var inProgressLivePhotoCapturesCount = 0
	private var livePhotoMode: LivePhotoMode = .off

	func toggleLivePhotoMode() {

		sessionQueue.async { [unowned self] in
			self.livePhotoMode = (self.livePhotoMode == .on) ? .off : .on
			let livePhotoMode = self.livePhotoMode

			DispatchQueue.main.async { [unowned self] in
				self.cameraViewDelegate.observeLivePhotoModeSelected = livePhotoMode
			}
		}
	}

}
