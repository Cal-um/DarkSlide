//
//  CollectionViewDataSource.swift
//  DarkSlide
//
//  Created by Calum Harris on 08/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class CollectionViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UICollectionViewCell>: NSObject, UICollectionViewDataSource where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object {

	required init(collectionView: UICollectionView, dataProvider: Data, delegate: Delegate) {
		self.collectionView = collectionView
		self.dataProvider = dataProvider
		self.delegate = delegate
		super.init()
		collectionView.dataSource = self
		collectionView.reloadData()

	}

	var numberOfItemsInView: Int {
		return dataProvider.numberOfItemsInSection(0)
	}

	var selectedObject: Data.Object? {
		guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
		return dataProvider.objectAtIndexPath(indexPath)
	}

	func selectedObjectAtIndexPath(_ indexPath: IndexPath) -> Delegate.Object {
		return dataProvider.objectAtIndexPath(indexPath)
	}

	// swiftlint:disable force_cast
	// After an undefined amount of updates the indexPath returns nil and the app will crash. Find out what is going on. This was only noticed after switching to a fetched results controller and background thread.

	func processUpdates(_ updates: [DataProviderUpdate<Data.Object>]?) {
		guard let updates = updates else { return collectionView.reloadData() }
		collectionView.performBatchUpdates({
			for update in updates {
				switch update {
				case .insert(let indexPath):
					print("inserted")
					self.collectionView.insertItems(at: [indexPath])
				case .update(_, _):
					//let checkForNil		= self.collectionView.objectAtIndex(at: indexPath)
					//guard let cell = self.collectionView.cellForItem(at: indexPath) as? Cell else { fatalError("wrong cell type") }
					//cell.configureCell(object)
					break
				case .move(let indexPath, let newIndexPath):
					self.collectionView.deleteItems(at: [indexPath])
					self.collectionView.insertItems(at: [newIndexPath])
				case .delete(let indexPath):
					self.collectionView.deleteItems(at: [indexPath])
				}
			}
		}, completion: nil)
	}

	// MARK: Private

	fileprivate let collectionView: UICollectionView
	fileprivate let dataProvider: Data
	fileprivate weak var delegate: Delegate!

	// MARK: CollectionViewDataSource

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataProvider.numberOfItemsInSection(section)
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let object = dataProvider.objectAtIndexPath(indexPath)
		let identifier = delegate.cellIdentifierForObject(object)
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else { fatalError("Unexpected cell type at \(indexPath)") }
		cell.configureCell(object)
		return cell
	}

}
