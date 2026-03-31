//
//  AppDateFormatters.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 31.03.2026.
//

import Foundation

enum AppDateFormatters {

	private static let locale: Locale = {
		Locale(identifier: "ru-RU")
	}()

	static let time: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.timeStyle = .short
		formatter.dateStyle = .none
		return formatter
	}()

	static let hour: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "HH:mm"
		return formatter
	}()

	static let date: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEE, d MMM"
		return formatter
	}()
}
