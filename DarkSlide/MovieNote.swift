//
//  MovieNote.swift
//  DarkSlide
//
//  Created by Calum Harris on 22/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

public final class MovieNote: ManagedObject {

	@NSManaged public var movieReferenceNumber: String
	@NSManaged public var subject: SubjectForExposure
}

extension MovieNote: ManagedObjectType, ExposureNote {

	public static var entityName: String {
		return "MovieNote"
	}

	// moviePath gives you the location of the movie.

	var moviePath: URL {
		let filename = "Movie-\(movieReferenceNumber).mp4"
		return (FileManager.applicationSupportDirectory.appendingPathComponent(filename))
	}

	static var randomReferenceNumber: String {
		return NSUUID().uuidString
	}

	var exposureNoteTypeIdentifier: NoteType {
		return NoteType.movie
	}

	// this function is used for when saving to applcations directory or when Managed Object has not been yet created.
	static func generateMoviePath(movieReferenceNumber: String) -> URL {
		let fileName = "Movie-\(movieReferenceNumber).mp4"
		return (FileManager.applicationSupportDirectory.appendingPathComponent(fileName))
	}

	func removeMovieFile() {
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
