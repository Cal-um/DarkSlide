//
//  WebService.swift
//  DarkSlide
//
//  Created by Calum Harris on 26/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

// swiftlint:disable force_cast

import UIKit

final class WebService {
	func load<A>(resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
		URLSession.shared.dataTask(with: resource.url) { data, response, error in

			// Check for errors in responses.
			guard error == nil else {
				if (error as! NSError).domain == NSURLErrorDomain && ((error as! NSError).code == NSURLErrorNotConnectedToInternet || (error as! NSError).code == NSURLErrorTimedOut) {
					return completion(.failure(.noInternetConnection))
				} else {
					return completion(.failure(.returnedError(error!))) }
			}

			guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
				return completion(.failure(.invalidStatusCode("Request returned status code other than 2xx \(response)")))
			}

			guard let data = data else { return completion(.failure(.dataReturnedNil)) }

			completion(resource.parse(data))

			}.resume()
	}
}

enum Result<T> {
	case success(T)
	case failure(NetworkingErrors)
}

enum NetworkingErrors: Error {
	case errorParsingJSON
	case noInternetConnection
	case dataReturnedNil
	case returnedError(Error)
	case invalidStatusCode(String)
}
