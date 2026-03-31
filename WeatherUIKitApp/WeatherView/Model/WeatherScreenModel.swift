//
//  WeatherScreenModel.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import Foundation

struct WeatherScreenModel: Equatable {
	let current: CurrentWeatherViewData
	let hourly: [HourlyWeatherViewData]
	let forecast3Days: [ForecastDayViewData]
}

struct CurrentWeatherViewData: Equatable {
	let city: String
	let temperature: String
	let condition: String
	let feelsLike: String
	let wind: String
	let humidity: String
	let iconURL: URL?
	let updatedAt: String
}

struct HourlyWeatherViewData: Equatable {
	let time: String
	let temperature: String
	let iconURL: URL?
}

struct ForecastDayViewData: Equatable {
	let date: String
	let minMax: String
	let condition: String
	let iconURL: URL?
}
