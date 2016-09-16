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
	
	@NSManaged public var audioRecording: Data
	@NSManaged public var audioTranscript: String?
	@NSManaged public var subject: SubjectForExposure
}
