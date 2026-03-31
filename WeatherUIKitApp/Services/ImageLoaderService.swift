//
//  ImageLoaderService.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import UIKit

protocol ImageLoaderServiceProtocol {
	func load(url: URL?) async -> UIImage?
}

final class ImageLoaderService: ImageLoaderServiceProtocol {

	// MARK: - Private Properties
	
	private let cache = NSCache<NSURL, UIImage>()
	private let session: URLSession

	// MARK: - Init

	init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: - Public Methods

	func load(url: URL?) async -> UIImage? {
		guard let url else { return nil }

		if let cached = cache.object(forKey: url as NSURL) {
			return cached
		}

		do {
			let (data, response) = try await session.data(from: url)
			guard
				let http = response as? HTTPURLResponse,
				(200...299).contains(http.statusCode),
				let image = UIImage(data: data)
			else {
				return nil
			}

			cache.setObject(image, forKey: url as NSURL)
			return image
		} catch {
			return nil
		}
	}
}
