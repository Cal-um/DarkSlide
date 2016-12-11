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

// swiftlint:disable force_try

extension ManagedObjectType where Self: ManagedObject {

	static public func findInContext(_ moc: NSManagedObjectContext, matchingPredicate predicate: NSCompoundPredicate) -> Self? {

		for obj in moc.registeredObjects where !obj.isFault {
			print("checking")
			print(obj)
			guard let res = obj as? Self, predicate.evaluate(with: res) else { continue }
			print(res)
			return res
		}
		return nil
	}

	public static func fetchInContext(_ context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> [Self] {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
		configurationBlock(request)
		guard let result = try! context.fetch(request) as? [Self] else { fatalError("Fetched objects have wrong type") }
		return result
	}
}
