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

class ExposureViewController: UIViewController, ManagedObjectContextStackSettable {

	var managedObjectContextStack: ManagedObjectContextStack!
	var subject: SubjectForExposure!
	var exposureNotes: [ExposureNote] = []

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var collectionView: UICollectionView!

	override func viewDidLoad() {
		if let image = subject.imageOfSubject {
			imageView.image = UIImage(data: image)
		}
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
		managedObjectContextStack.mainContext.delete(subject)
		managedObjectContextStack.mainContext.trySave()

		performSegue(withIdentifier: "unwindToRoot", sender: nil)
	}

	@IBAction func saveSubjectAndUnwind(_ sender: Any) {
		 managedObjectContextStack.backgroundContext.trySave()
		performSegue(withIdentifier: "unwindToRoot", sender: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print(sender ?? "bones")
		switch segue.identifier {
		case .some("ExposurePhotoVideoViewControllerSegue"):
			guard let vc = segue.destination as? ExposurePhotoVideoViewController else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
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
}

extension ExposureViewController: CameraOutputDelegate {

	func didTakePhoto(image: UIImage, livePhoto: String?) {
		let photo = PhotoNote.insertIntoContext(moc: self.managedObjectContextStack.backgroundContext, photoNote: image, livePhotoRefNumber: livePhoto, subjectForExposure: self.subject)
		managedObjectContextStack.backgroundContext.trySave()
		self.exposureNotes.insert(photo, at: 0)
		let paths = [IndexPath(row: 0, section: 0)]
		self.collectionView.insertItems(at: paths)
	}

	func didTakeVideo(videoReferenceNumber: String) {
		// test that shows that video does save.
		print(MovieNote.generateMoviePath(movieReferenceNumber: videoReferenceNumber))
		DispatchQueue.global(qos: .utility).async {
			let video = MovieNote.insertIntoContext(moc: self.managedObjectContextStack.mainContext, movieReferenceNumber: videoReferenceNumber, subjectForExposure: self.subject)
			DispatchQueue.main.async {
				self.exposureNotes.insert(video, at: 0)
				let paths = [IndexPath(row: 0, section: 0)]
				self.collectionView.insertItems(at: paths)
			}
		}
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
		case .photo((let lowResImage, _), _):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoNote", for: indexPath) as? PhotoNoteCell else { fatalError("Wrong cell type") }
			cell.imageView.image = lowResImage
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
		case .photo((_, let image), let reference):

			let tuple: (UIImage, String?) = (image, reference)
			performSegue(withIdentifier: "ExposurePreviewImageSegue", sender: tuple as Any)

		case .movie(let url):
			let player = AVPlayer(url: url)
			let playerController = AVPlayerViewController()
			playerController.player = player
			self.present(playerController, animated: true) {
				playerController.player!.play()
			}

		case .audio(let url):
			let player = AVPlayer(url: url)
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
		DispatchQueue.global(qos: .utility).async {
			let audio = AudioNote.insertIntoContext(moc: self.managedObjectContextStack.mainContext, audioURL: fileReferenceNumber, subjectForExposure: self.subject)
			DispatchQueue.main.async {
				self.exposureNotes.insert(audio, at: 0)
				let paths = [IndexPath(row: 0, section: 0)]
				self.collectionView.insertItems(at: paths)
			}
		}
	}
}
