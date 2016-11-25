//
//  CoreDataStack.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

// Define Model URL.
private let storeURL = URL.documentsURL.appendingPathComponent("Model.DarkSlide")

// Create Main Context with model objects in Bundles and add PSC.
public func getMainContext() -> NSManagedObjectContext? {
	let bundles = [Bundle(for: MovieNote.self), Bundle(for: SubjectForExposure.self), Bundle(for: PhotoNote.self), Bundle(for: DarkSlide.self),Bundle(for: AudioNote.self)]
	guard let model = NSManagedObjectModel.mergedModel(from: bundles) else { fatalError("Model not found") }
	
	let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
	try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
	let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	moc.persistentStoreCoordinator = psc
	moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
	return moc
}

extension NSManagedObjectContext {
	
	// Generic insert into Context function where object must conform to the ManagedObject protocol.
	
	public func insertObject<A: ManagedObject>() -> A where A: ManagedObjectType {
		guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
		return obj
	}
	
	// Create a Context on a background queue with same PSC as self.
	
	public func createBackgroundContext() -> NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
		return context
	}
	
	// Save context
	
	func trySave() {
		
		self.performAndWait() {
			
			if self.hasChanges {
				do {
					try self.save()
					print("save")
				} catch {
					fatalError("Error while saving main context \(error)")
				}
			}
		}
	}
}

