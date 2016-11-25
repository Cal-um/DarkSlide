//
//  HelperExtensions.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

// swiftlint:disable force_try

import Foundation

// Helper to shorten CoreData Stack documents URL.

extension URL {

	static var documentsURL: URL {
		return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
	}
}
