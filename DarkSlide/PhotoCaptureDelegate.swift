//
//  PhotoCaptureDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 21/10/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import AVFoundation
import Photos

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
	private(set) var requestedPhotoSettings: AVCapturePhotoSettings

	private let willCapturePhotoAnimation: () -> ()

	private let capturingLivePhoto: (Bool) -> ()

	private let completed: (PhotoCaptureDelegate) -> ()

	private var photoData: Data? = nil

	private var livePhotoCompanionMovieURL: URL? = nil

	private let cameraViewDelegate: CameraViewDelegate!

	init(with requestedPhotoSettings: AVCapturePhotoSettings, delegate: CameraViewDelegate, willCapturePhotoAnimation: @escaping () -> (), capturingLivePhoto: @escaping (Bool) -> (), completed: @escaping (PhotoCaptureDelegate) -> ()) {
		self.requestedPhotoSettings = requestedPhotoSettings
		self.willCapturePhotoAnimation = willCapturePhotoAnimation
		self.capturingLivePhoto = capturingLivePhoto
		self.completed = completed
		self.cameraViewDelegate = delegate
	}

	private func didFinish() {
		if let livePhotoCompanionMoviePath = livePhotoCompanionMovieURL?.path {
			if FileManager.default.fileExists(atPath: livePhotoCompanionMoviePath) {
				do {
					try FileManager.default.removeItem(atPath: livePhotoCompanionMoviePath)
				} catch {
					print("Could not remove file at url: \(livePhotoCompanionMoviePath)")
				}
			}
		}

		completed(self)
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, willBeginCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
		if resolvedSettings.livePhotoMovieDimensions.width > 0 && resolvedSettings.livePhotoMovieDimensions.height > 0 {
			capturingLivePhoto(true)
		}
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, willCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
		willCapturePhotoAnimation()
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
		if let photoSampleBuffer = photoSampleBuffer {
			photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
		} else {
			print("Error capturing photo: \(error)")
			return
		}
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
		capturingLivePhoto(false)
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplay photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
		if let _ = error {
			print("Error processing live photo companion movie: \(error)")
			return
		}

		livePhotoCompanionMovieURL = outputFileURL
	}

	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
		if let error = error {
			print("Error capturing photo: \(error)")
			didFinish()
			return
		}

		guard let photoData = photoData else {
			print("No photo data resource")
			didFinish()
			return
		}

		let photo = UIImage(data: photoData)!

		if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {

			let livePhotoReferenceNumber = PhotoNote.randomReferenceNumber

			do {
				let livePhoto = try Data(contentsOf: livePhotoCompanionMovieURL)
				try livePhoto.write(to: PhotoNote.generateLivePhotoPath(livePhotoReferenceNumber: livePhotoReferenceNumber))
				cameraViewDelegate.didTakePhoto(image: photo, livePhoto: livePhotoReferenceNumber)
				didFinish()
			} catch {
				print("Error saving livePhotoFile")
				didFinish()
			}
		} else {
			cameraViewDelegate.didTakePhoto(image: photo, livePhoto: nil)
		}
	}
}
