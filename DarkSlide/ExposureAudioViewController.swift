//
//  ExposureAudioViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 19/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ExposureAudioNoteViewController: UIViewController, ManagedObjectContextStackSettable {
	
	var managedObjectContextStack: ManagedObjectContextStack!
	
	@IBAction func dismissViewController(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		print(view.bounds)
	}
}


