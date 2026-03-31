//
//  WeatherViewModel.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import Foundation

@MainActor
final class WeatherViewModel {

	// MARK: - Public Properties

	enum State {
		case loading
		case loaded(WeatherScreenModel)
		case error(String)
	}

	var onStateChange: ((State) -> Void)?

	// MARK: - Private Properties

	private let locationService: LocationServiceProtocol
	private let repository: WeatherRepositoryProtocol

	private var isRefreshing = false

	// MARK: - Init

	init(
		locationService: LocationServiceProtocol,
		repository: WeatherRepositoryProtocol
	) {
		self.locationService = locationService
		self.repository = repository
	}

	// MARK: - Public Methods

	func refresh() {
		guard !isRefreshing else { return }
		isRefreshing = true
		onStateChange?(.loading)

		Task {
			let coords = await locationService.requestLocation()
			do {
				let model = try await repository.fetchWeather(coordinates: coords)
				onStateChange?(.loaded(model))
			} catch {
				let weatherError = error as? WeatherError ?? .unknown
				onStateChange?(.error(weatherError.userMessage))
			}
			isRefreshing = false
		}
	}
}
