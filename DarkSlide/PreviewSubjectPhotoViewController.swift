//
//  PreviewSubjectPhotoViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class PreviewSubjectPhotoViewController: UIViewController, ManagedObjectContextStackSettable {
	
	var subjectPhoto: UIImage!
	var managedObjectContextStack: ManagedObjectContextStack!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var choosePhotoButton: UINavigationItem!
	
	override func viewDidLoad() {
		imageView.image = subjectPhoto
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Chosen Photo Segue" {
			guard var vc = segue.destination as? ManagedObjectContextStackSettable else { fatalError("wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		}
	}
}
