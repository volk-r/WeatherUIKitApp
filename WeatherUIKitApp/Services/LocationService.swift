//
//  LocationService.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import CoreLocation

protocol LocationServiceProtocol {
	func requestLocation() async -> Coordinates
}

final class LocationService: NSObject {

	// MARK: - Private Properties

	private enum Constants {
		static let defaultLocation = Coordinates(latitude: 55.7558, longitude: 37.6173)
	}

	private let manager = CLLocationManager()
	private var continuation: CheckedContinuation<Coordinates, Never>?

	// MARK: - Init

	override init() {
		super.init()
		manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		manager.delegate = self
	}
}

// MARK: - LocationServicing

extension LocationService: LocationServiceProtocol {

	func requestLocation() async -> Coordinates {
		switch manager.authorizationStatus {
		case .notDetermined:
			manager.requestWhenInUseAuthorization()
		case .restricted, .denied:
			return Constants.defaultLocation
		case .authorizedAlways, .authorizedWhenInUse:
			manager.requestLocation()
		@unknown default:
			return Constants.defaultLocation
		}

		return await withCheckedContinuation { (continuation: CheckedContinuation<Coordinates, Never>) in
			self.continuation = continuation
		}
	}
}

// MARK: - Private Methods

private extension LocationService {

	func complete(with coords: Coordinates) {
		continuation?.resume(returning: coords)
		continuation = nil
	}
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
		case .authorizedAlways, .authorizedWhenInUse:
			manager.requestLocation()
		case .denied, .restricted:
			complete(with: Constants.defaultLocation)
		case .notDetermined:
			break
		@unknown default:
			complete(with: Constants.defaultLocation)
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let loc = locations.first else {
			complete(with: Constants.defaultLocation)
			return
		}
		complete(with: Coordinates(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		complete(with: Constants.defaultLocation)
	}
}
