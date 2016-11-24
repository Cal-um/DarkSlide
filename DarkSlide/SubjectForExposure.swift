//
//  SubjectForExposure.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public final class SubjectForExposure: ManagedObject {
	
	// Some properties are defined with private(set) to disable changes. The remaining properties may be updated at a later time to allow concurrency.
	
	@NSManaged public private(set) var imageOfSubject: Data
	@NSManaged public private(set) var dateOfExposure: Date
	@NSManaged public var locationLat: Double
	@NSManaged public var locationLong: Double
	@NSManaged public var compassHeading: Double
	
	// Relationship properties
	
	@NSManaged public var photoNotes: Set<PhotoNote>?
	@NSManaged public var darkSlideUsed: DarkSlide
	@NSManaged public var audioNote: Set<AudioNote>
}

extension SubjectForExposure: ManagedObjectType {
	
	public static var entityName: String {
		return "SubjectForExposure"
	}
}
