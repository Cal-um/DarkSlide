//
//  PhotoNote.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public final class PhotoNote: ManagedObject {
	
	@NSManaged public var photoNote: Data
	@NSManaged public var subject: SubjectForExposure
}
