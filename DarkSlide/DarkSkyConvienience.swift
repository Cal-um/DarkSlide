//
//  DarkSkyConvienience.swift
//  DarkSlide
//
//  Created by Calum Harris on 26/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

struct DarkSkyConvienience {

	static func fetchSevenDayForecast(_ lat: Double, _ long: Double, completion: @escaping (Result<[DailyForecast]>) -> ()) {

		let parseDailyForecasts = Resource<[DailyForecast]>(url: DarkSkyConvienience.assembleURLFrom(lat, long), parseJSON: { jsonData in
			guard let json = jsonData as? JSONDictionary, let daily = json["daily"] as? JSONDictionary, let data = daily["data"] as? [JSONDictionary] else { return .failure(.errorParsingJSON)  }
			return .success(data.flatMap(DailyForecast.init))
		})
		WebService().load(resource: parseDailyForecasts) { result in
			completion(result)
		}
	}
}

extension DarkSkyConvienience {

	struct URLKeys {
		static let ApiKey = "f73d72e148d083e3fe4fec5c9441fee6"
		static let BaseURL = "https://api.darksky.net/forecast/"
	}

	static func assembleURLFrom(_ lat: Double, _ long: Double) -> URL {
		let url = URL(string: "\(DarkSkyConvienience.URLKeys.BaseURL)\(DarkSkyConvienience.URLKeys.ApiKey)/\(lat),\(long)")!
		return url
	}
}

typealias JSONDictionary = [String : Any]

struct DailyForecast {

	let timeStamp: Double
	let summary: String
	let icon: String
	let sunsetTime: Double
	let sunriseTime: Double
	let moonPhase: Double
	let maxTemp: Double
	let minTemp: Double
	let cloudCover: Double
}

extension DailyForecast {

	init?(dictionary: JSONDictionary) {

		guard let timeStamp = dictionary["time"] as? Double, let summary = dictionary["summary"] as? String, let icon = dictionary["icon"] as? String, let sunsetTime = dictionary["sunsetTime"] as? Double, let sunriseTime = dictionary["sunriseTime"] as? Double, let moonPhase = dictionary["moonPhase"] as? Double, let minTemp = dictionary["temperatureMin"] as? Double, let maxTemp = dictionary["temperatureMax"] as? Double, let cloudCover = dictionary["cloudCover"] as? Double else { return nil }

		self.timeStamp = timeStamp
		self.summary = summary
		self.icon = icon
		self.sunsetTime = sunsetTime
		self.sunriseTime = sunriseTime
		self.moonPhase = moonPhase
		self.maxTemp = maxTemp
		self.minTemp = minTemp
		self.cloudCover = cloudCover
	}
}

extension DailyForecast {

	func getDayOfTheWeek() -> String {

		guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else { fatalError("error initialising calendar") }
		let component = calendar.component(.weekday, from: Date(timeIntervalSince1970: self.timeStamp))
		print(component)
		switch component {
		case 1: return "Sunday"
		case 2: return "Monday"
		case 3: return "Tuesday"
		case 4: return "Wednesday"
		case 5: return "Thursday"
		case 6: return "Friday"
		case 7: return "Saturday"
		default: fatalError("issue with component conversion")
		}
	}

	func convertImageLiteralString() -> String {
		switch self.icon {
		case "clear-day": return "Sunshine"
		case "rain": return "Rain"
		case "snow": return "Snow"
		case "sleet": return "Sleet"
		case "wind": return "Wind"
		case "fog": return "Fog"
		case "cloudy": return "Clouds"
		case "partly-cloudy-day": return "PartlyCloudy"
		case "partly-cloudy-night": return "Sunshine"
		default: fatalError("issue with converting image literal string")
		}
	}
}
