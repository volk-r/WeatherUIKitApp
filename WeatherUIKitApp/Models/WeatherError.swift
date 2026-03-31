//
//  WeatherError.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 31.03.2026.
//

import Foundation

enum WeatherError: Error, Equatable {
	case invalidResponse
	case httpStatus(Int)
	case emptyData
	case decoding
	case unknown

	static func from(_ error: Error) -> WeatherError {
		if let weatherError = error as? WeatherError { return weatherError }
		if error is DecodingError { return .decoding }
		return .unknown
	}

	var userMessage: String {
		switch self {
		case .invalidResponse:
			return "Неожиданный ответ сервера."
		case .httpStatus(let code):
			return "Ошибка сервера (HTTP \(code))."
		case .emptyData:
			return "Пустой ответ от сервера."
		case .decoding:
			return "Не удалось обработать данные о погоде."
		case .unknown:
			return "Что-то пошло не так. Повторите попытку."
		}
	}
}
