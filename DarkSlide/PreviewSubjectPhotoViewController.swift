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
	var subjectPhoto: UIImage!
	var latitude: Double?
	var longitude: Double?
	var compassBearing: Double?
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var choosePhotoButton: UINavigationItem!
	
	override func viewDidLoad() {
		imageView.image = subjectPhoto
	}
	@IBAction func tryAgainAction(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Chosen Photo Segue" {
			guard let nc = segue.destination as? UINavigationController, var vc = nc.viewControllers.first as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		}
	}
}

