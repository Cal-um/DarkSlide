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

	override func viewDidLoad() {
		splitViewController?.delegate = self
		collectionView?.register(UINib(nibName: "RootCell", bundle: nil), forCellWithReuseIdentifier: "RootCell")
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Flowlayout set to 2 per row.
		guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
		let width = view.bounds.width / 2.5
		layout.itemSize = CGSize(width: width, height: width * 1.25)
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
}

extension RootColletionViewController {

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 6
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RootCell", for: indexPath) as? RootCollectionViewCell else { fatalError("wrong cell type") }
		return cell
	}
}

extension RootColletionViewController: UISplitViewControllerDelegate {

	// This ensures that the first screen displayed in portrait mode is self.
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}

}
