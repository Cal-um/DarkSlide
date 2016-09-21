//
//  PhotoNote.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

public final class PhotoNote: ManagedObject {
	
	@NSManaged public var photoNote: Data
	
	// Relationship properties
	
	@NSManaged public var subject: SubjectForExposure?
}

extension PhotoNote: ManagedObjectType {
	
	public static var entityName: String {
		return "PhotoNote"
	}
}
