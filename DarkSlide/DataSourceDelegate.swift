//
//  DataSourceDelegate.swift
//  DarkSlide
//
//  Created by Calum Harris on 08/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

protocol DataSourceDelegate: class {
	associatedtype Object
	func cellIdentifierForObject(_ object: Object) -> String
}
