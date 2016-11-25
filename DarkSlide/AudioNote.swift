//
//  AudioNote.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public final class AudioNote: ManagedObject {

	@NSManaged public var audioRecordingReferenceNumber: String
	@NSManaged public var audioTranscript: String?

	// Relationship properties

	@NSManaged public var subject: SubjectForExposure
}

extension AudioNote: ManagedObjectType, ExposureNote {

	public static var entityName: String {
		return "AudioNote"
	}

	var audioPath: URL {
		let filename = "Audio-\(audioRecordingReferenceNumber).wav"
		return (FileManager.applicationSupportDirectory.appendingPathComponent(filename))
	}

	static var randomReferenceNumber: String {
		return NSUUID().uuidString
	}

	// this function is used for when saving to applcations directory or when Managed Object has not been yet created.
	static func generateMoviePath(audioReferenceNumber: String) -> URL {
		let fileName = "Audio-\(audioReferenceNumber).wav"
		return (FileManager.applicationSupportDirectory.appendingPathComponent(fileName))
	}

	func removeMovieFile() {
		let path = audioPath
		let fileManager = FileManager.default
		if fileManager.fileExists(atPath: path.path) {
			do {
				try fileManager.removeItem(atPath: path.path)
			} catch {
				print("Error removing file: \(error)")
			}
		}
	}

	var exposureNoteTypeIdentifier: NoteType {
		return NoteType.audio
	}

}
