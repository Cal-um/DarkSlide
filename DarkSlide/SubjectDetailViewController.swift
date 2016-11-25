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
	
	
	override func viewDidLoad() {
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		navigationItem.leftItemsSupplementBackButton = true
		navigationItem.leftBarButtonItem?.title = "Select Exposure"
	}
	
	
	
	
}
