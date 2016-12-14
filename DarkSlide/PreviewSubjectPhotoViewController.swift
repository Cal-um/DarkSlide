//
//  PreviewSubjectPhotoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

class PreviewSubjectPhotoViewController: UIViewController, ManagedObjectContextSettable {

	var managedObjectContext: NSManagedObjectContext!
	var subjectPhoto: Data!
	var thumbnailImage: Data!
	var latitude: Double?
	var longitude: Double?
	var compassHeading: Double?
	var subject: SubjectForExposure?
	
	
	weak var delegate: PreviewSubjectPhotoViewControllerDelegate!

	@IBOutlet weak var imageView: UIImageView!
	
	deinit {
		print("PreviewSubjectPhotoViewController DEINIT")
	}

	override func viewDidLoad() {
		imageView.image = UIImage(data: subjectPhoto)
	}

	@IBAction func tryAgainAction(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func choosePhotoAction(_ sender: Any) {
		delegate.loadOnAppear = false
		subject = SubjectForExposure.insertIntoContext(moc: managedObjectContext, imageOfSubject: subjectPhoto, thumbnailImage: thumbnailImage, locationLat: latitude, locationLong: longitude, compassHeading: compassHeading)
		managedObjectContext.trySave()
		performSegue(withIdentifier: "Chosen Photo Segue", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Chosen Photo Segue" {
			guard let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? ExposureViewController else { fatalError("wrong view controller type") }
			vc.managedObjectContext = managedObjectContext
			vc.subject = subject
		}
	}
}
