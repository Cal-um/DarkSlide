//
//  File.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public final class SubjectForExposure: ManagedObject {
	
	@NSManaged public private(set) var imageOfSubject: Data
	@NSManaged public private(set) var dateOfExposure: Date
	@NSManaged public var locationLat: Double
	@NSManaged public var locationLong: Double
	@NSManaged public var compassHeading: Double
	
	@NSManaged public var photoNote: Set<PhotoNote>
	@NSManaged public var darkSlideUsed: DarkSlide
	@NSManaged public var audioNote: Set<AudioNote>
}
