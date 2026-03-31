//
//  WeatherMapper.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 31.03.2026.
//

import Foundation

enum WeatherMapper {

	static func map(current: WeatherAPICurrentResponseDTO, forecast: WeatherAPIForecastResponseDTO) -> WeatherScreenModel {
		let city = forecast.location.name

		let currentView = CurrentWeatherViewData(
			city: city,
			temperature: formatTemp(current.current.tempC),
			condition: current.current.condition.text,
			feelsLike: "Ощущается как \(formatTemp(current.current.feelslikeC))",
			wind: "Ветер \(formatWind(current.current.windKph))",
			humidity: "Влажность \(current.current.humidity)%",
			iconURL: iconURL(from: current.current.condition.icon),
			updatedAt: "Обновлено \(formatTime(epoch: current.current.lastUpdatedEpoch))"
		)

		let hourly = mapHourly(forecast: forecast)
		let days = forecast.forecast.forecastday.prefix(3).map(mapDay)

		return WeatherScreenModel(current: currentView, hourly: hourly, forecast3Days: Array(days))
	}

	private static func mapHourly(forecast: WeatherAPIForecastResponseDTO) -> [HourlyWeatherViewData] {
		let now = forecast.location.localtimeEpoch
		let days = forecast.forecast.forecastday
		guard !days.isEmpty else { return [] }

		let todayHours = days[0].hour.filter { $0.timeEpoch >= now }
		let tomorrowHours: [HourDTO]
		if days.count >= 2 {
			tomorrowHours = days[1].hour
		} else {
			tomorrowHours = []
		}

		return (todayHours + tomorrowHours).map {
			HourlyWeatherViewData(
				time: formatHour(epoch: $0.timeEpoch),
				temperature: formatTemp($0.tempC),
				iconURL: iconURL(from: $0.condition.icon)
			)
		}
	}

	private static func mapDay(_ day: ForecastDayDTO) -> ForecastDayViewData {
		ForecastDayViewData(
			date: formatDate(epoch: day.dateEpoch),
			minMax: "\(formatTemp(day.day.mintempC)) / \(formatTemp(day.day.maxtempC))",
			condition: day.day.condition.text,
			iconURL: iconURL(from: day.day.condition.icon)
		)
	}

	private static func iconURL(from apiIconPath: String) -> URL? {
		let trimmed = apiIconPath.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmed.isEmpty { return nil }
		if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
			return URL(string: trimmed)
		}
		return URL(string: "https:\(trimmed)")
	}

	private static func formatTemp(_ celsius: Double) -> String {
		"\(Int(round(celsius)))°"
	}

	private static func formatWind(_ kph: Double) -> String {
		"\(Int(round(kph))) км/ч"
	}

	private static func formatTime(epoch: Int) -> String {
		Date.formatTime(epoch: epoch)
	}

	private static func formatHour(epoch: Int) -> String {
		Date.formatHour(epoch: epoch)
	}

	private static func formatDate(epoch: Int) -> String {
		Date.formatDate(epoch: epoch)
	}
}
