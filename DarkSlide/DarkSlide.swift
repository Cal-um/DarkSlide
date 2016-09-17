//
//  DarkSlide.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public final class DarkSlide: ManagedObject {
	
	@NSManaged public var refNumber: Double
	@NSManaged public var filmType: String
	
	// Relationship properties
	@NSManaged public var subject: SubjectForExposure?
}
