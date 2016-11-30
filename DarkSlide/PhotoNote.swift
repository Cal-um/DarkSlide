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
	@NSManaged public var livePhotoReferenceNumber: String?

	// Relationship properties

	@NSManaged public var subject: SubjectForExposure

	// this variable was added to improve collectionView scroll perfomance.
	var lowResCachedThumbnail: UIImage?
	var highResCachedThumbnail: UIImage?
}

extension PhotoNote: ManagedObjectType, ExposureNote {

	public static var entityName: String {
		return "PhotoNote"
	}

	var exposureNoteTypeIdentifier: NoteType {

		if let lowResCachedThumbnail = lowResCachedThumbnail, let highResCachedThumbnail = highResCachedThumbnail {
			return NoteType.photo((lowRes: lowResCachedThumbnail, highRes: highResCachedThumbnail), livePhotoRef: livePhotoReferenceNumber)
		} else {
			lowResCachedThumbnail = UIImage(data: photoNote, scale: 0)
			highResCachedThumbnail = UIImage(data:photoNote, scale: 1)
			return self.exposureNoteTypeIdentifier
		}
	}

	var livePhotoPath: URL? {
		if let _ = livePhotoReferenceNumber {
			let filename = "LivePhoto-\(livePhotoReferenceNumber).mp4"
			return (FileManager.applicationSupportDirectory.appendingPathComponent(filename))
		} else {
			print("No live photo attached to this record")
			return nil
		}
	}

	static var randomReferenceNumber: String {
		return NSUUID().uuidString
	}

	// this function is used for when saving to applcations directory or when Managed Object has not been yet created.
	static func generateLivePhotoPath(livePhotoReferenceNumber: String) -> URL {
		let fileName = "LivePhoto-\(livePhotoReferenceNumber).mp4"
		return (FileManager.applicationSupportDirectory.appendingPathComponent(fileName))
	}

	func removeLivePhotoFile() {
		if let path = livePhotoPath {
			let fileManager = FileManager.default
			if fileManager.fileExists(atPath: path.path) {
				do {
					try fileManager.removeItem(atPath: path.path)
				} catch {
					print("Error removing file: \(error)")
				}
			}
		}
	}

	static func insertIntoContext(moc: NSManagedObjectContext, photoNote photo: UIImage, livePhotoRefNumber ref: String?, subjectForExposure subject: SubjectForExposure) -> PhotoNote {

		let photoNote: PhotoNote = moc.insertObject()
		photoNote.photoNote = UIImageJPEGRepresentation(photo, 1)!
		photoNote.livePhotoReferenceNumber = (ref != nil) ? ref : nil
		photoNote.subject = subject
		return photoNote
	}
}
