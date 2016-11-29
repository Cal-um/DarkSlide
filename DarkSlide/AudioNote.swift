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

	@NSManaged public var audioRecordingURL: String
	@NSManaged public var audioTranscript: String?

	// Relationship properties

	@NSManaged public var subject: SubjectForExposure
}

extension AudioNote: ManagedObjectType, ExposureNote {

	public static var entityName: String {
		return "AudioNote"
	}

	var audioPath: URL {
		return URL(string: audioRecordingURL)!
	}

	static var randomReferenceNumber: String {
		return NSUUID().uuidString
	}

	// this function is used for when saving to applcations directory or when Managed Object has not been yet created.
	static func generateAudioPath(audioReferenceNumber: String) -> URL {
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
		return NoteType.audio(url: self.audioPath)
	}
	
	static func insertIntoContext(moc: NSManagedObjectContext, audioURL url: String, subjectForExposure subject: SubjectForExposure) -> AudioNote {
		
		let audioNote: AudioNote = moc.insertObject()
		audioNote.audioRecordingURL = url
		audioNote.subject = subject
		return audioNote
	}

}
