//
//  SubjectForExposure.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

public final class SubjectForExposure: ManagedObject {

	// Some properties are defined with private(set) to disable changes. The remaining properties may be updated at a later time to allow concurrency.

	@NSManaged public var imageOfSubject: Data
	@NSManaged public var thumbnailImage: Data
	@NSManaged public var dateOfExposure: Date
	@NSManaged public var locationLat: NSNumber?
	@NSManaged public var locationLong: NSNumber?
	@NSManaged public var compassHeading: NSNumber?

	// Relationship properties

	@NSManaged public var photoNotes: Set<PhotoNote>?
	@NSManaged public var darkSlideUsed: DarkSlide?
	@NSManaged public var audioNote: Set<AudioNote>?
	@NSManaged public var movieNote: Set<MovieNote>?

	lazy var lowResImage: UIImage? = {
		return UIImage(data: self.thumbnailImage, scale: 1)
	}()
}

extension SubjectForExposure: ManagedObjectType {

	public static var entityName: String {
		return "SubjectForExposure"
	}

	static func insertIntoContext(moc: NSManagedObjectContext, imageOfSubject image: Data, thumbnailImage thumbnail: Data, locationLat lat: Double?, locationLong long: Double?, compassHeading heading: Double?) -> SubjectForExposure {

		let subject: SubjectForExposure = moc.insertObject()
		subject.imageOfSubject = image
		subject.thumbnailImage = thumbnail
		subject.dateOfExposure = Date()

		if let lat = lat, let long = long {
			subject.locationLong = NSNumber(value: long)
			subject.locationLat = NSNumber(value: lat)
		}

		if let heading = heading {
			subject.compassHeading = NSNumber(value: heading)
		}
		return subject
	}
}
