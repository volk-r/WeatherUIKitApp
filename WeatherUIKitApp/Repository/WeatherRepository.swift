//
//  WeatherRepository.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import Foundation

protocol WeatherRepositoryProtocol {
	func fetchWeather(coordinates: Coordinates) async throws -> WeatherScreenModel
}

final class WeatherRepository: WeatherRepositoryProtocol {

	// MARK: - Private Properties

	private let api: WeatherAPIClientProtocol

	// MARK: - Init

	init(api: WeatherAPIClientProtocol = WeatherAPIClient()) {
		self.api = api
	}

	// MARK: - Public Methods

	func fetchWeather(coordinates: Coordinates) async throws -> WeatherScreenModel {
		do {
			async let current = api.fetchCurrent(coordinates: coordinates)
			async let forecast = api.fetchForecast3Days(coordinates: coordinates)

			let (currentDTO, forecastDTO) = try await (current, forecast)
			return WeatherMapper.map(current: currentDTO, forecast: forecastDTO)
		} catch {
			throw WeatherError.from(error)
		}
	}
}
