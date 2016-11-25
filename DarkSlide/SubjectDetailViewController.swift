//
//  SubjectDetailViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import MapKit

class SubjectDetailViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var viewWeatherForecastButton: UIBarButtonItem!
	@IBOutlet weak var subjectImageView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var coordinatesLabel: UILabel!
	@IBOutlet weak var facingLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func viewDidLoad() {
		collectionView?.delegate = self
		collectionView?.dataSource = self
		collectionView?.register(UINib(nibName: "PhotoNoteCell", bundle: nil), forCellWithReuseIdentifier: "PhotoNote")
		collectionView?.register(UINib(nibName: "AudioNoteCell", bundle: nil), forCellWithReuseIdentifier: "AudioNote")
		collectionView?.register(UINib(nibName: "MovieNoteCell", bundle: nil), forCellWithReuseIdentifier: "MovieNote")
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		navigationItem.leftItemsSupplementBackButton = true
		navigationItem.leftBarButtonItem?.title = "Select Exposure"
	}
	
	override func viewDidLayoutSubviews() {
		guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
		let width = collectionView.bounds.height
		layout.itemSize = CGSize(width: width, height: width)
		//layout.sectionInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
	}
	
	let testArray = [1,1,3,2,2,3,2,3,1,1,1]
}


extension SubjectDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return testArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch testArray[indexPath.row] {
		case 1:
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoNote", for: indexPath) as? PhotoNoteCell else { fatalError("Wrong cell type") }
			return cell
		case 2: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieNote", for: indexPath)
			return cell
		case 3: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioNote", for: indexPath)
			return cell
		default: fatalError("Incorrect Cell at index path")
		}
	}
}
