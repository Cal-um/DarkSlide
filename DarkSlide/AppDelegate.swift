//
//  AppDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 16/09/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Answers

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var managedObjectContext: NSManagedObjectContext!
	var managedObjectContextStack: ManagedObjectContextStack!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		// CoreData init main context and assign to managedObjectContext property before passing to MOCStack.
		guard let mainContext = getMainContext() else { fatalError("Init main context failure") }
		managedObjectContext = mainContext
		managedObjectContextStack = ManagedObjectContextStack(mainManagedObjectContext: managedObjectContext)

		// Pass MOCStack to rootViewController.

		guard let svc = window?.rootViewController as? UISplitViewController, let nc = svc.viewControllers.first as? UINavigationController, var vc = nc.viewControllers.first as? ManagedObjectContextStackSettable else {
			fatalError("Wrong view controller type")
		}

		vc.managedObjectContextStack = managedObjectContextStack

		Fabric.with([Answers.self])

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func applicationWillTerminate(_ application: UIApplication) {
	}
}
