//
//  PhotoCaptureDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 21/10/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import AVFoundation
import UIKit
import Photos

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

	deinit {
		print("PhotoCaptureDelegate DEINIT")
	}

	private(set) var requestedPhotoSettings: AVCapturePhotoSettings

	private let willCapturePhotoAnimation: () -> ()

	private let capturingLivePhoto: (Bool) -> ()

	private let completed: (PhotoCaptureDelegate) -> ()

	private var photoData: Data? = nil
	private var previewImage: UIImage? = nil

	private var livePhotoCompanionMovieURL: URL? = nil

	private let cameraViewDelegate: CameraViewDelegate!

	private let cameraOutputDelegate: CameraOutputDelegate!

	init(with requestedPhotoSettings: AVCapturePhotoSettings, cameraViewDelegate: CameraViewDelegate, cameraOutputDelegate: CameraOutputDelegate, willCapturePhotoAnimation: @escaping () -> (), capturingLivePhoto: @escaping (Bool) -> (), completed: @escaping (PhotoCaptureDelegate) -> ()) {
		self.requestedPhotoSettings = requestedPhotoSettings
		self.willCapturePhotoAnimation = willCapturePhotoAnimation
		self.capturingLivePhoto = capturingLivePhoto
		self.completed = completed
		self.cameraViewDelegate = cameraViewDelegate
		self.cameraOutputDelegate = cameraOutputDelegate
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
		if let photoSampleBuffer = photoSampleBuffer, let previewPhotoSampleBuffer = previewPhotoSampleBuffer {
			photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: nil)
			let imageOrientation = UIImage(data: photoData!, scale: 0)?.imageOrientation
			let previewBuff = CMSampleBufferGetImageBuffer(previewPhotoSampleBuffer)
			let ciPreview = CIImage(cvPixelBuffer: previewBuff!)
			let cgPreview = CIContext(options: nil).createCGImage(ciPreview, from: ciPreview.extent)
			previewImage = UIImage(cgImage: cgPreview!, scale: 0.3, orientation: imageOrientation!)

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

		guard let photoData = photoData, let previewImage = previewImage else {
			print("No photo data resource")
			didFinish()
			return
		}

		let thumbnailData = UIImageJPEGRepresentation(previewImage, 0.2)!
		let byte = ByteCountFormatter()
		print("FULL IMAGE \(byte.string(fromByteCount: Int64(photoData.count)))")
		print("PREVIEW IMAGE \(byte.string(fromByteCount: Int64(thumbnailData.count)))")

		if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {

			let livePhotoReferenceNumber = PhotoNote.randomReferenceNumber

			do {
				let livePhoto = try Data(contentsOf: livePhotoCompanionMovieURL)
				try livePhoto.write(to: PhotoNote.generateLivePhotoPath(livePhotoReferenceNumber: livePhotoReferenceNumber))
				cameraOutputDelegate.didTakePhoto(jpeg: photoData, thumbnail: thumbnailData, livePhoto: livePhotoReferenceNumber)
				didFinish()
			} catch {
				print("Error saving livePhotoFile")
				didFinish()
			}
		} else {
			cameraOutputDelegate.didTakePhoto(jpeg: photoData, thumbnail: thumbnailData, livePhoto: nil)
			didFinish()
		}
	}
}
