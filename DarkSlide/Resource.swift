//
//  Resource.swift
//  DarkSlide
//
//  Created by Calum Harris on 26/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

struct Resource<A> {
	let url: URL
	let parse: (Data) -> Result<A>
}

extension Resource {

	init(url: URL, parseJSON: @escaping (Any) -> Result<A>) {
		self.url = url
		self.parse = { data	in
			do {
				let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
				return parseJSON(jsonData)
			} catch {
				fatalError("Error parsing data")
			}
		}
	}
}
