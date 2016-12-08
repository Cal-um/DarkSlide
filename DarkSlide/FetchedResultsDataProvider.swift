//
//  FetchedResultsDataProvider.swift
//  DarkSlide
//
//  Created by Calum Harris on 08/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, DataProvider, NSFetchedResultsControllerDelegate {
	
	typealias Object = Delegate.Object
	
	init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, delegate: Delegate) {
		self.fetchedResultsController = fetchedResultsController
		self.delegate = delegate
		super.init()
		fetchedResultsController.delegate = self
		try! fetchedResultsController.performFetch()
		
	}
	
	func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
		guard let result = fetchedResultsController.object(at: indexPath) as? Object else { fatalError("Unexpected object at \(indexPath)") }
		return result
	}
	
	func numberOfItemsInSection(_ section: Int) -> Int {
		guard let sec = fetchedResultsController.sections?[section] else { return 0 }
		return sec.numberOfObjects
	}
	
	// MARK: Private
	
	fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
	fileprivate weak var delegate: Delegate!
	fileprivate var updates: [DataProviderUpdate<Object>] = []
	
	// MARK: NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		print("hi")
		updates = []
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		print(123)
		switch type {
		case .insert:
			guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
			updates.append(.insert(indexPath))
		case .update:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			let object = objectAtIndexPath(indexPath)
			updates.append(.update(indexPath, object))
		case .move:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
			updates.append(.move(indexPath, newIndexPath))
		case .delete:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			updates.append(.delete(indexPath))
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate.dataProviderDidUpdate(updates)
		print("changed")
	}
}
