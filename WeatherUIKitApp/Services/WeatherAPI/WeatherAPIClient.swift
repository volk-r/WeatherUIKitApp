//
//  WeatherAPIClient.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import Foundation

protocol WeatherAPIClientProtocol {
	func fetchCurrent(coordinates: Coordinates) async throws -> WeatherAPICurrentResponseDTO
	func fetchForecast3Days(coordinates: Coordinates) async throws -> WeatherAPIForecastResponseDTO
}

final class WeatherAPIClient: WeatherAPIClientProtocol {

	// MARK: - Private Properties

	private enum Constants {
		static let baseURL = URL(string: "https://api.weatherapi.com")!
		static let apiKey = "fa8b3df74d4042b9aa7135114252304"

		static let defaultQueryItems: [URLQueryItem] = [
			URLQueryItem(name: "key", value: Constants.apiKey),
			URLQueryItem(name: "lang", value: "ru")
		]
	}

	private let session: URLSession

	private lazy var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()

	// MARK: - Init

	init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: - Public Methods

	func fetchCurrent(coordinates: Coordinates) async throws -> WeatherAPICurrentResponseDTO {
		let request = makeRequest(
			path: "/v1/current.json",
			queryItems: Constants.defaultQueryItems + [
				URLQueryItem(name: "q", value: "\(coordinates.latitude),\(coordinates.longitude)")
			]
		)
		return try await execute(request: request)
	}

	func fetchForecast3Days(coordinates: Coordinates) async throws -> WeatherAPIForecastResponseDTO {
		let request = makeRequest(
			path: "/v1/forecast.json",
			queryItems: Constants.defaultQueryItems + [
				URLQueryItem(name: "q", value: "\(coordinates.latitude),\(coordinates.longitude)"),
				URLQueryItem(name: "days", value: "3")
			]
		)
		return try await execute(request: request)
	}
}

// MARK: - Private Methods

private extension WeatherAPIClient {

	func makeRequest(path: String, queryItems: [URLQueryItem]) -> URLRequest {
		var components = URLComponents(url: Constants.baseURL, resolvingAgainstBaseURL: false)!
		components.path = path
		components.queryItems = queryItems
		var request = URLRequest(url: components.url!)
		request.timeoutInterval = 15
		request.cachePolicy = .reloadIgnoringLocalCacheData
		return request
	}

	private func execute<T: Decodable>(request: URLRequest) async throws -> T {
		let (data, response) = try await session.data(for: request)

		guard let http = response as? HTTPURLResponse else {
			throw WeatherError.invalidResponse
		}

		guard (200...299).contains(http.statusCode) else {
			throw WeatherError.httpStatus(http.statusCode)
		}

		do {
			return try decoder.decode(T.self, from: data)
		} catch {
			throw WeatherError.decoding
		}
	}
}
