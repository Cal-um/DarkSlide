//
//  RootTableViewCell.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class RootCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
}

extension RootCollectionViewCell: ConfigurableCell {

	func configureCell(_ subject: SubjectForExposure) {
		imageView.image = subject.lowResImage
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		titleLabel.text = formatter.string(from: subject.dateOfExposure)
	}
	
	func nameCell() {
		print("RootCell")
	}
}
