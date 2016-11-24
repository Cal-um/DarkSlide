//
//  SubjectDetailViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class SubjectDetailViewController: UIViewController {
	
	override func viewDidLoad() {
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		navigationItem.leftItemsSupplementBackButton = true
		navigationItem.leftBarButtonItem?.title = "Select Exposure"
	}
	
	
}
