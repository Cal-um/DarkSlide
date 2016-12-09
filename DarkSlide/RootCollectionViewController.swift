//
//  RootCollectionViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

class RootCollectionViewController: UICollectionViewController, ManagedObjectContextStackSettable {

	var managedObjectContextStack: ManagedObjectContextStack!

	override func viewDidLoad() {
		splitViewController?.delegate = self
		collectionView?.register(UINib(nibName: "RootCell", bundle: nil), forCellWithReuseIdentifier: "RootCell")
		setUpCollectionView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Flowlayout set to 2 per row.
		guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
		let width = view.bounds.width / 2.5
		layout.itemSize = CGSize(width: width, height: width * 1.25)
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}

	fileprivate typealias SubjectsDataProvider = FetchedResultsDataProvider<RootCollectionViewController>
	fileprivate var dataSource: CollectionViewDataSource<RootCollectionViewController, SubjectsDataProvider, RootCollectionViewCell>!

	private func setUpCollectionView() {
		let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SubjectForExposure")
		request.sortDescriptors = [NSSortDescriptor(key: "dateOfExposure", ascending: true)]
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContextStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
		let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShootSubjectSegue" {
			guard let vc = segue.destination as? SubjectCameraViewController else { fatalError("Wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		}
	}

	@IBAction func unwindToRoot(_ seg: UIStoryboardSegue!) {
	}
}

extension RootCollectionViewController: DataSourceDelegate {

	func cellIdentifierForObject(_ object: SubjectForExposure) -> String {
		return "RootCell"
	}
}

extension RootCollectionViewController: DataProviderDelegate {
	func dataProviderDidUpdate(_ updates: [DataProviderUpdate<SubjectForExposure>]?) {
		print("updates")
		dataSource.processUpdates(updates)
	}
}

extension RootCollectionViewController: UISplitViewControllerDelegate {

	// This ensures that the first screen displayed in portrait mode is self.
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}
}
