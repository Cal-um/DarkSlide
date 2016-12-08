//
//  RootCollectionViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

class RootColletionViewController: UICollectionViewController, ManagedObjectContextStackSettable {

	var managedObjectContextStack: ManagedObjectContextStack!
	var savedSubjects: [SubjectForExposure]!

	override func viewDidLoad() {
		splitViewController?.delegate = self
		collectionView?.register(UINib(nibName: "RootCell", bundle: nil), forCellWithReuseIdentifier: "RootCell")
		savedSubjects = initialFetchRequest()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Flowlayout set to 2 per row.
		guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
		let width = view.bounds.width / 2.5
		layout.itemSize = CGSize(width: width, height: width * 1.25)
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShootSubjectSegue" {
			guard let vc = segue.destination as? SubjectCameraViewController else { fatalError("Wrong view controller type") }
			vc.managedObjectContextStack = managedObjectContextStack
		}
	}
	
	@IBAction func unwindToRoot(_ seg:UIStoryboardSegue!) {
		print("UNWOUNDROOT")
		savedSubjects = initialFetchRequest()
		collectionView?.reloadData()
	}
	
	// swiftlint:disable force_try

	func initialFetchRequest() -> [SubjectForExposure] {
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SubjectForExposure")
		guard let result = try! managedObjectContextStack.mainContext.fetch(fetchRequest) as? [SubjectForExposure] else { fatalError("Objects have wrong entity type") }
		return result
	}
}

extension RootColletionViewController {

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return savedSubjects.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RootCell", for: indexPath) as? RootCollectionViewCell else { fatalError("wrong cell type") }
		cell.imageView.image = savedSubjects[indexPath.row].lowResImage
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_GB")
		cell.titleLabel.text = String(describing: savedSubjects[indexPath.row].dateOfExposure)
		print(formatter.string(from: savedSubjects[indexPath.row].dateOfExposure)
)
		return cell
	}
}

extension RootColletionViewController: UISplitViewControllerDelegate {

	// This ensures that the first screen displayed in portrait mode is self.
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}

}
