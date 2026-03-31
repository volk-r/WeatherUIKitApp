//
//  WeatherAPIModels.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import Foundation

struct WeatherAPICurrentResponseDTO: Decodable {
	let location: LocationDTO
	let current: CurrentDTO
}

struct WeatherAPIForecastResponseDTO: Decodable {
	let location: LocationDTO
	let current: CurrentDTO
	let forecast: ForecastDTO
}

struct LocationDTO: Decodable {
	let name: String
	let region: String
	let country: String
	let lat: Double
	let lon: Double
	let tzId: String
	let localtimeEpoch: Int
	let localtime: String
}

struct CurrentDTO: Decodable {
	let lastUpdatedEpoch: Int
	let tempC: Double
	let feelslikeC: Double
	let windKph: Double
	let humidity: Int
	let condition: ConditionDTO
	let isDay: Int
}

struct ConditionDTO: Decodable {
	let text: String
	let icon: String
	let code: Int
}

struct ForecastDTO: Decodable {
	let forecastday: [ForecastDayDTO]
}

struct ForecastDayDTO: Decodable {
	let date: String
	let dateEpoch: Int
	let day: DayDTO
	let hour: [HourDTO]
}

struct DayDTO: Decodable {
	let maxtempC: Double
	let mintempC: Double
	let condition: ConditionDTO
}

struct HourDTO: Decodable {
	let timeEpoch: Int
	let time: String
	let tempC: Double
	let isDay: Int
	let condition: ConditionDTO
}
