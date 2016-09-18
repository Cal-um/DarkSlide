//
//  PhotoAudioVideo.swift
//  DarkSlide
//
//  Created by Calum Harris on 18/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoAudioVideo: NSObject, AVCapturePhotoCaptureDelegate {
	
	let captureSession = AVCaptureSession()
	let imageOutput = AVCapturePhotoOutput()
	let movieOutput = AVCaptureMovieFileOutput()
	var activeInput: AVCaptureDeviceInput!
	var previewLayer: AVCaptureVideoPreviewLayer!
	var cameraViewDelegate: CameraViewDelegate!
	
	init(cameraViewDelegate: CameraViewDelegate) {
		super.init()
		self.cameraViewDelegate = cameraViewDelegate
		self.initPreviewAndStartSession()
	}
	
	func initPreviewAndStartSession() {
		if setUpCaptureSession() {
			setUpPreview()
			startSession()
		}
	}
	
	func setUpCaptureSession() -> Bool {
		
		captureSession.sessionPreset = AVCaptureSessionPresetHigh
		
		// setup camera
		let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		
		do {
			let input = try AVCaptureDeviceInput(device: camera)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
				activeInput = input
			}
		} catch {
			print("Error setting device video input \(error)")
			return false
		}
		
		// set up microphone
		let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
		
		do {
			let micInput = try AVCaptureDeviceInput(device: microphone)
			if captureSession.canAddInput(micInput) {
				captureSession.addInput(micInput)
			}
		} catch {
			print("Error setting device audio input \(error)")
			return false
		}
		
		// Still image output
		if captureSession.canAddOutput(imageOutput) {
			captureSession.addOutput(imageOutput)
		}
		
		// Movie output
		if captureSession.canAddOutput(movieOutput) {
			captureSession.canAddOutput(movieOutput)
		}
		return true
	}

	func videoQueue() -> DispatchQueue {
		return DispatchQueue(label: "session queue", attributes: [], target: nil)
	}
	
	func startSession() {
		if !captureSession.isRunning {
			videoQueue().async {
				self.captureSession.startRunning()
				print("yy")
			}
		}
	}
	
	func setUpPreview() {
		//configure the preview layer
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		cameraViewDelegate.cameraView.layer.addSublayer(previewLayer)
		
	}
	
	func takePhoto() {
		let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
		settings.flashMode = .auto
		imageOutput.capturePhoto(with: settings, delegate: self)
		
	}
	
	

	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
		print("meow")
		if let error = error {
			print(error.localizedDescription)
		}
		print("proot")
		if let photoSample = photoSampleBuffer, let photo = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSample, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
		print(UIImage(data: photo)?.size)
		}
	}
	
}
