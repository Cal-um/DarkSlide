//
//  ManagedObject.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObject: NSManagedObject {
}

public protocol ManagedObjectType: class {
	static var entityName: String { get }
}
