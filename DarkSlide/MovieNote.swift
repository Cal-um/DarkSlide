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
	
	@NSManaged var movieReferenceNumber: String
	@NSManaged var subject: SubjectForExposure?
	
	var moviePath: URL {
		let filename = "Movie-\(movieReferenceNumber)"
		return (FileManager.applicationSupportDirectory.appendingPathComponent(filename))
	}
}

extension MovieNote: ManagedObjectType, ExposureNote {
	
	static var entityName: String {
		return "MovieNote"
	}
	
	static var randomReferenceNumber: String {
		return NSUUID().uuidString
	}
	
	var exposureNoteTypeIdentifier: NoteType {
		return NoteType.movie
	}
	
	//photoPath gives you the location of the photo
	func removePhotoFile() {
		let path = moviePath
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
