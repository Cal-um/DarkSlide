//
//  PreviewSubjectPhotoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class PreviewSubjectPhotoViewController: UIViewController, ManagedObjectContextStackSettable {

	var managedObjectContextStack: ManagedObjectContextStack!
	var subjectPhoto: UIImage?
	var latitude: Double?
	var longitude: Double?
	var compassHeading: Double?
	var subject: SubjectForExposure?

	@IBOutlet weak var imageView: UIImageView!

	override func viewDidLoad() {
		imageView.image = subjectPhoto
	}

	@IBAction func tryAgainAction(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func choosePhotoAction(_ sender: Any) {

		subject = SubjectForExposure.insertIntoContext(moc: managedObjectContextStack.backgroundContext, imageOfSubject: subjectPhoto, locationLat: latitude, locationLong: longitude, compassHeading: compassHeading)
		managedObjectContextStack.backgroundContext.trySave()
		performSegue(withIdentifier: "Chosen Photo Segue", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Chosen Photo Segue" {
			guard let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? ExposureViewController else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
			vc.subject = subject
		}
	}
}
