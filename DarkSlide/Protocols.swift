//
//  Protocols.swift
//  DarkSlide
//
//  Created by Calum Harris on 19/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol ManagedObjectContextStackSettable {
	var managedObjectContextStack: ManagedObjectContextStack! { get set }
}

protocol ExposureNote {
	var exposureNoteTypeIdentifier: NoteType { get }
}

enum NoteType {
	case audio(url: URL)
	case movie(url: URL)
	case photo((lowRes: UIImage, highRes: UIImage), livePhotoRef: String?)
}

protocol ConfigurableCell {
	associatedtype DataSource
	func configureCell(_ object: DataSource)
}
