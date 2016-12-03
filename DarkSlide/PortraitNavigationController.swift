//
//  PortraitNavigationController.swift
//  DarkSlide
//
//  Created by Calum Harris on 20/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class PortraitNavigationController: UINavigationController {

	override var shouldAutorotate: Bool {
		return false
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
}
