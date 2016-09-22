//
//  MovieNote.swift
//  DarkSlide
//
//  Created by Calum Harris on 22/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

class MovieNote: ManagedObject {
	
	@NSManaged var movieNote: Data
	@NSManaged var subject: SubjectForExposure?
}

extension MovieNote: ManagedObjectType {
	
	static var entityName: String {
		return "MovieNote"
	}
}
