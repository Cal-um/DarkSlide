//
//  Protocols.swift
//  DarkSlide
//
//  Created by Calum Harris on 19/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

protocol ManagedObjectContextStackSettable {
	var managedObjectContextStack: ManagedObjectContextStack! { get set }
}

protocol ExposureNote {
	var exposureNoteTypeIdentifier: NoteType { get }
}

enum NoteType {
	case audio
	case movie
	case photo
}
