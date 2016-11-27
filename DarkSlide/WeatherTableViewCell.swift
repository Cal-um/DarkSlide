//
//  WeatherTableViewCell.swift
//  DarkSlide
//
//  Created by Calum Harris on 26/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

	@IBOutlet weak var dayOfTheWeekLabel: UILabel!
	@IBOutlet weak var summaryLabel: UILabel!
	@IBOutlet weak var cloudCoverLabel: UILabel!
	@IBOutlet weak var maxTempLabel: UILabel!
	@IBOutlet weak var minTempLabel: UILabel!
	@IBOutlet weak var weatherIcon: UIImageView!
}
