//
//  CoreDataStack.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

private let StoreURL = URL.documentsURL.appendingPathComponent("Model.DarkSlide")

public func getMainContext() -> NSManagedObjectContext? {
	
	let bundles = [Bundle(for: SubjectForExposure.self), Bundle(for: PhotoNote.self), Bundle(for: DarkSlide.self),Bundle(for: AudioNote.self)]
	guard let model = NSManagedObjectModel.mergedModel(from: bundles) else { fatalError("Model not found") }
	
	let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
	try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: StoreURL, options: nil)
	let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	moc.persistentStoreCoordinator = psc
	moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
	return moc
}


extension URL {
	
	static var documentsURL: URL {
		return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
	}
}


extension NSManagedObjectContext {
	
	public func insertObject<A: ManagedObject>() -> A where A: ManagedObjectType {
		
		guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
		return obj
	}
	
	public func createBackgroundContext() -> NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
		return context
	}
	
	// This saves the context called from
	
	func trySave() {
		
		self.performAndWait() {
			
			if self.hasChanges {
				do {
					try self.save()
				} catch {
					fatalError("Error while saving main context \(error)")
				}
			}
		}
	}
}

