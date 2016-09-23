//
//  Utilities.swift
//  DarkSlide
//
//  Created by Calum Harris on 19/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

extension FileManager {
	// find or create applicationSupportDirectory for Movie and Audio saves.
	public static var applicationSupportDirectory: URL {
	do {
		let path = try self.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			return path
	} catch {
			fatalError("Failed to obtain or create applicationSupportDirectory")
		}
	}
}
