//
//  ManagedObjectContextStack.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

struct ManagedObjectContextStack {

	// This pattern was taken from ObjC's book on CoreData. There are two contexts connected to the same PSC. One acts on the main contexts and the other on a background context. This allows concurrent actions to work on the background. When the background context saves an NSNotification is picked up by the mainContext and the changes are merged.

	let mainContext: NSManagedObjectContext!
	let backgroundContext: NSManagedObjectContext!

	init(mainManagedObjectContext mainContext: NSManagedObjectContext) {
		self.mainContext = mainContext
		self.backgroundContext = mainContext.createBackgroundContext()
		setUpNotificationsForBackgroundContext()
		print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
	}

	fileprivate func setUpNotificationsForBackgroundContext() {

		let notificationCentre = NotificationCenter.default
		notificationCentre.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext, queue: nil) { notification in
			self.mainContext.mergeChanges(fromContextDidSave: notification)
		}
	}
}
