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
	var typeIdentifier: NoteType { get }
}

extension ExposureNote {
	
	func getExposureNote() -> NoteType {
		switch self {
		case is PhotoNote:
			return .photo
		case is AudioNote:
			return .audio
		case is MovieNote:
			return .movie
		default: fatalError("ExposureNote is not of correct type")
		}
	}
}

enum NoteType {
	case audio
	case movie
	case photo
}
