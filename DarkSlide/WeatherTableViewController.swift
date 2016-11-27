//
//  WeatherTableViewController.swift
//  DarkSlide
//
//  Created by Calum Harris on 24/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class WeatherViewController: UITableViewController {

	var sevenDayWeather: [DailyForecast]?
  let pullToRefresh = UIRefreshControl()
	let downloadQueue = DispatchQueue(label: "WeatherQueue", qos: .utility, target: nil)

	override func viewDidLoad() {
		pullToRefresh.addTarget(self, action: #selector(self.pullToRefreshAction), for: .valueChanged)
		tableView.addSubview(pullToRefresh)
		navigationItem.title = "Loading..."
		loadSevenDayForecast() { _ in
			self.navigationItem.title = ""

		}
	}

	@IBAction func exitScreen(_ sender: Any)
 {
	dismiss(animated: true, completion: nil)
	}
	func pullToRefreshAction() {
		loadSevenDayForecast(completion: { _ in
			DispatchQueue.main.async { [unowned self] in
				self.pullToRefresh.endRefreshing()
				self.tableView.reloadData()
			}
		})
	}

	func loadSevenDayForecast(completion: @escaping () -> ()) {

		downloadQueue.async { [unowned self] in
			DarkSkyConvienience.fetchSevenDayForecast(55.8643, 4.2518) { [unowned self] result in
				switch result {
				case .success(let result):
					DispatchQueue.main.async { [unowned self] in
						var weather = result
						weather.removeLast()
						self.sevenDayWeather = weather
						print(weather)
						self.tableView.reloadData()
						completion()
					}
				case .failure(let error):
					switch error {
					case .noInternetConnection:
						DispatchQueue.main.async { _ in
							self.alertNoInternet()
							self.tableView.reloadData()
						}
					default: print(error)
					}
				}
			}
		}
	}

	func alertNoInternet() {
		let ac = UIAlertController(title: "Whoops", message: "No Internet Connection", preferredStyle: .alert)
		let okButton = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
			self.pullToRefresh.endRefreshing()
		})
		ac.addAction(okButton)
		present(ac, animated: true, completion: { self.navigationItem.title = "" })
	}
}

extension WeatherViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sevenDayWeather = sevenDayWeather else { return 0 }
		return sevenDayWeather.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		guard let cell = tableView.dequeueReusableCell(withIdentifier: "Weather Cell") as? WeatherTableViewCell else { fatalError("Wrong cell type") }
		if let sevenDayWeather = sevenDayWeather {
			let dailyForecast = sevenDayWeather[indexPath.row]
			cell.dayOfTheWeekLabel.text = dailyForecast.getDayOfTheWeek()
			cell.cloudCoverLabel.text = String(lround(dailyForecast.cloudCover * 100))
			cell.maxTempLabel.text = String(describing: lround(dailyForecast.maxTemp))
			cell.minTempLabel.text = String(describing: lround(dailyForecast.minTemp))
			cell.weatherIcon.image = UIImage(imageLiteralResourceName: dailyForecast.convertImageLiteralString())
			cell.summaryLabel.text = dailyForecast.summary

		}
		return cell
	}
}
