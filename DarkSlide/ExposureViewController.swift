//
//  ExposureViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 19/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit

class ExposureViewController: UIViewController, ManagedObjectContextSettable {

	var managedObjectContext: NSManagedObjectContext!
	var subject: SubjectForExposure!
	var exposureNotes: [ExposureNote] = []

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var collectionView: UICollectionView!

	override func viewDidLoad() {
		let image = subject.thumbnailImage
		imageView.image = UIImage(data: image)
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView?.register(UINib(nibName: "PhotoNoteCell", bundle: nil), forCellWithReuseIdentifier: "PhotoNote")
		collectionView?.register(UINib(nibName: "AudioNoteCell", bundle: nil), forCellWithReuseIdentifier: "AudioNote")
		collectionView?.register(UINib(nibName: "MovieNoteCell", bundle: nil), forCellWithReuseIdentifier: "MovieNote")
	}

	override func viewDidLayoutSubviews() {
		guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
		let width = collectionView.bounds.height
		layout.itemSize = CGSize(width: width, height: width)
	}

	@IBAction func discardSubjetAndUnwind(_ sender: Any) {
		deleteSavedFiles(input: exposureNotes)
		NotificationCenter.default.post(name: Notification.Name(NotificationIdentifiers.PhotoVideo.WillClosePreviewView), object: nil)
		managedObjectContext.delete(subject)
		performSegue(withIdentifier: "unwindToRoot", sender: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		print("ViewDissapeared 2")
	}

	@IBAction func saveSubjectAndUnwind(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(NotificationIdentifiers.PhotoVideo.WillClosePreviewView), object: nil)
		managedObjectContext.trySave()
		performSegue(withIdentifier: "unwindToRoot", sender: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case .some("ExposurePhotoVideoViewControllerSegue"):
			guard let vc = segue.destination as? ExposurePhotoVideoViewController else { fatalError("wrong view controller type") }
			vc.cameraOutputDelegate = self
			vc.audioOutputDelegate = self
		case .some("ExposurePreviewImageSegue") :
			guard let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? ImagePreviewViewController else { fatalError("wrong view controller type") }
			guard let data = sender as? (UIImage, String?) else { fatalError("Wrong sender type") }
			vc.highResPhotoWithLivePhotoRef = data
		default:
			break
		}
	}

	deinit {
		print("DEINIT ExposureViewController")
	}
}

extension ExposureViewController: CameraOutputDelegate {

	func didTakePhoto(jpeg: Data, thumbnail: Data, livePhoto: String?) {

		let photo = PhotoNote.insertIntoContext(moc: managedObjectContext, photoNote: jpeg, thumbnailImage: thumbnail, livePhotoRefNumber: livePhoto, subjectForExposure: self.subject)
		self.exposureNotes.insert(photo, at: 0)
		let paths = [IndexPath(row: 0, section: 0)]
		self.collectionView.insertItems(at: paths)
	}

	func didTakeVideo(videoReferenceNumber: String) {
		print(MovieNote.generateMoviePath(movieReferenceNumber: videoReferenceNumber))
			let video = MovieNote.insertIntoContext(moc: self.managedObjectContext, movieReferenceNumber: videoReferenceNumber, subjectForExposure: self.subject)
				self.exposureNotes.insert(video, at: 0)
				let paths = [IndexPath(row: 0, section: 0)]
				self.collectionView.insertItems(at: paths)
	}
}

extension ExposureViewController: UICollectionViewDelegate, UICollectionViewDataSource {

	// swiftlint:disable force_cast

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return exposureNotes.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let note = exposureNotes[indexPath.row]
		switch note.exposureNoteTypeIdentifier {
		case .photo(let photo):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoNote", for: indexPath) as? PhotoNoteCell else { fatalError("Wrong cell type") }
			cell.imageView.image = photo.lowResCachedThumbnail
			return cell
		case .movie: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieNote", for: indexPath)
		return cell
		case .audio: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioNote", for: indexPath)
		return cell
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let note = exposureNotes[indexPath.row]

		switch note.exposureNoteTypeIdentifier {
		case .photo(let photo):

			let tuple: (UIImage, String?) = (photo.highResImage, photo.livePhotoReferenceNumber)
			performSegue(withIdentifier: "ExposurePreviewImageSegue", sender: tuple as Any)

		case .movie(let url):
			let player = AVPlayer(url: url)
			let playerController = AVPlayerViewController()
			playerController.player = player
			self.present(playerController, animated: true) {
				playerController.player!.play()
			}

		case .audio(let path):
			let player = AVPlayer(url: path)
			let playerController = AVPlayerViewController()
			playerController.player = player
			self.present(playerController, animated: true) {
				playerController.player!.play()
			}
		}
	}
}

extension ExposureViewController: AudioNoteDelegate {

	func didSaveAudioRecording(fileReferenceNumber: String) {
			let audio = AudioNote.insertIntoContext(moc: self.managedObjectContext, audioURL: fileReferenceNumber, subjectForExposure: self.subject)
			self.exposureNotes.insert(audio, at: 0)
			let paths = [IndexPath(row: 0, section: 0)]
			self.collectionView.insertItems(at: paths)
	}
}

extension ExposureViewController {

	func deleteSavedFiles(input: [ExposureNote]) {

		func deleteFile(url: URL) {
			let fileManager = FileManager.default
				if fileManager.fileExists(atPath: url.path) {
					do {
						try fileManager.removeItem(atPath: url.path)
						print("Deleted")
					} catch {
						print("Error removing file: \(error)")
				}
			}
		}

		for i in input {
			switch i.exposureNoteTypeIdentifier {
			case .audio(let url):
				deleteFile(url: url)
			case .movie(let url):
				deleteFile(url: url)
			case .photo: break
			}
		}
	}
}
