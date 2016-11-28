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
	var exposureNotes: [ExposureNote] = [] {
		didSet {
			exposureNotes.count
			print(exposureNotes[0])
		}
	}

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

	@IBAction func dismissViewController(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}

	override func viewDidLayoutSubviews() {
		guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
		let width = collectionView.bounds.height
		layout.itemSize = CGSize(width: width, height: width)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ExposurePhotoVideoViewControllerSegue" {
			guard let vc = segue.destination as? ExposurePhotoVideoViewController else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
			vc.cameraOutputDelegate = self
		}
	}
}

extension ExposureViewController: CameraOutputDelegate {

	func didTakePhoto(image: UIImage, livePhoto: String?) {

	//	if let _ = livePhoto {

	//	}
	//	else {
			print(image)
			print(exposureNotes.count)
			let photo: PhotoNote = managedObjectContextStack.mainContext.insertObject()
			photo.photoNote = UIImageJPEGRepresentation(image, 0.2)!
			photo.subject = subject
			exposureNotes.insert(photo, at: 0)
			var paths = [IndexPath]()
			paths.append(IndexPath(row: 0, section: 0))
			collectionView.insertItems(at: paths)
		//}

//		if let livePhoto = livePhoto {
//			let player = AVPlayer(url: PhotoNote.generateLivePhotoPath(livePhotoReferenceNumber: livePhoto))
//			let playerController = AVPlayerViewController()
//			playerController.player = player
//			self.present(playerController, animated: true) {
//				playerController.player!.play()
//			}
//		}
	}

	func didTakeVideo(videoReferenceNumber: String) {

		// test that shows that video does save.
		print(MovieNote.generateMoviePath(movieReferenceNumber: videoReferenceNumber))
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
		case .photo(let image):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoNote", for: indexPath) as? PhotoNoteCell else { fatalError("Wrong cell type") }
			cell.imageView.image = image
			return cell
		case .movie: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieNote", for: indexPath)
		return cell
		case .audio: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioNote", for: indexPath)
		return cell
		default: fatalError("Incorrect Cell at index path")
		}

	}
}
