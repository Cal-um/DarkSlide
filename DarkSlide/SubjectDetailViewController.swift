//
//  SubjectDetailViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import AVKit

class SubjectDetailViewController: UIViewController {

	// MOC properties
	var subject: SubjectForExposure?
	var exposureNotes: [ExposureNote] = []
	//IB properties
	@IBOutlet weak var showWeatherButton: UIBarButtonItem!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var viewWeatherForecastButton: UIBarButtonItem!
	@IBOutlet weak var subjectImageView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var coordinatesLabel: UILabel!
	@IBOutlet weak var facingLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var darkSlideTitle: UILabel!

	// View life cycle
	override func viewDidLoad() {
		if subject == nil {
			hideAllAndShowLabel()
		} else {

			collectionView?.delegate = self
			collectionView?.dataSource = self
			collectionView?.register(UINib(nibName: "PhotoNoteCell", bundle: nil), forCellWithReuseIdentifier: "PhotoNote")
			collectionView?.register(UINib(nibName: "AudioNoteCell", bundle: nil), forCellWithReuseIdentifier: "AudioNote")
			collectionView?.register(UINib(nibName: "MovieNoteCell", bundle: nil), forCellWithReuseIdentifier: "MovieNote")
					configureLabels()
			fetchNotes() { results in
				exposureNotes = results
				collectionView.reloadData()
			}
			setMapView()
		}
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		navigationItem.leftItemsSupplementBackButton = true

	}

	// swiftlint:disable force_cast

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}

	func setMapView() {

		guard let lat = subject?.locationLat as? Double, let long = subject?.locationLong as? Double else { return }
		mapView.isScrollEnabled = false
		mapView.isZoomEnabled = false
		let span = MKCoordinateSpanMake(0.030, 0.030)
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
		mapView.setRegion(region, animated: true)
		let annotation = MKPointAnnotation()
		annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
		mapView.addAnnotation(annotation)
	}

	func hideAllAndShowLabel() {
		mapView.isHidden = true
		subjectImageView.isHidden = true
		collectionView.isHidden = true
		stackView.isHidden = true
		darkSlideTitle.isHidden = false
	}

	func fetchNotes(completion: ([ExposureNote]) -> ()) {

		guard let subject = subject else { fatalError("subject is nil") }

		var exposureNotes: [ExposureNote] = []

		let photoNotes: [PhotoNote] = PhotoNote.fetchInContext(subject.managedObjectContext!) { (request) -> () in
			request.predicate = NSPredicate(format: "subject = %@", argumentArray: [subject])
			request.returnsObjectsAsFaults = false
		}
		let audioNotes: [AudioNote] = AudioNote.fetchInContext(subject.managedObjectContext!) { (request) -> () in
			request.predicate = NSPredicate(format: "subject = %@", argumentArray: [subject])
			request.returnsObjectsAsFaults = false
		}
		let movieNotes: [MovieNote] = MovieNote.fetchInContext(subject.managedObjectContext!) { (request) -> () in
			request.predicate = NSPredicate(format: "subject = %@", argumentArray: [subject])
			request.returnsObjectsAsFaults = false
		}

		for i in photoNotes {
			exposureNotes.append(i)
		}

		for i in audioNotes {
			exposureNotes.append(i)
		}

		for i in movieNotes {
			exposureNotes.append(i)
		}

		completion(exposureNotes)
	}

	func configureLabels() {

		guard let subject = subject else { fatalError("subject is nil") }

		let date: String = {
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			return dateFormatter.string(from: subject.dateOfExposure)
		}()

		let coordinates: String = {
			if let latitude = subject.locationLat as? Double, let longitude = subject.locationLong as? Double {
				showWeatherButton.isEnabled = true
				var lat = Double(round(latitude * 100) / 100)
				var long = Double(round(longitude * 1000) / 1000)
				let latNS: String
				let longEW: String

				if lat >= 0 {
					latNS = "N"
				} else {
					latNS = "S"
					lat = lat * -1
				}

				if long >= 0 {
					longEW = "E"
				} else {
					longEW = "W"
					long = long * -1
				}
				return "\(lat) \(latNS), \(long) \(longEW)"
			} else {
				return "N/A"
			}
		}()

		let heading: String = {
			if let bearing = subject.compassHeading as? Double {
				switch bearing {
				case 0..<22.5: return "N"
				case 22.5..<67.5: return "NE"
				case 67.5..<112.5: return "E"
				case 112.5..<157.5: return "SE"
				case 157.5..<202.5: return "S"
				case 202.5..<247.5: return "SW"
				case 247.5..<292.5: return "W"
				case 292.5..<337.5: return "NW"
				case 337.5...360: return "N"
				default: return "N/A"
				}
			} else {
				return "N/A"
			}
		}()

		subjectImageView.image = subject.lowResImage
		dateLabel.text = "Date: \(date)"
		coordinatesLabel.text = "Coordinates: \(coordinates)"
		facingLabel.text = "Bearing: \(heading)"
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		guard let subject = subject else { fatalError("subject is nil") }

		switch segue.identifier {
		case .some("SubjectDetailImagePreviewSegue"):
			guard let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? ImagePreviewViewController else { fatalError("wrong view controller type") }
			guard let data = sender as? (UIImage, String?) else { fatalError("Wrong sender type") }
			vc.highResPhotoWithLivePhotoRef = data
		case .some("WeatherSegue"):
			guard let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? WeatherViewController else { fatalError("wrong view controller type") }
			vc.latitude = subject.locationLat as! Double
			vc.longitude = subject.locationLong as! Double
		default: break
		}
	}

	deinit {
		print("SubjectDetailViewController DEINIT")
	}
}

extension SubjectDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
			performSegue(withIdentifier: "SubjectDetailImagePreviewSegue", sender: tuple as Any)

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

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let height = collectionView.bounds.height
		return CGSize(width: height, height: height)
	}
}
