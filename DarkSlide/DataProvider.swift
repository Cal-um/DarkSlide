//
//  DataProvider.swift
//  DarkSlide
//
//  Created by Calum Harris on 08/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol DataProvider: class {
	associatedtype Object
	func objectAtIndexPath(_ indexPath: IndexPath) -> Object
	func numberOfItemsInSection(_ section: Int) -> Int
}

protocol DataProviderDelegate: class {
	associatedtype Object
	func dataProviderDidUpdate(_ updates: [DataProviderUpdate<Object>]?)
}

enum DataProviderUpdate<Object> {
	case insert(IndexPath)
	case update(IndexPath, Object)
	case move(IndexPath, IndexPath)
	case delete(IndexPath)
}

