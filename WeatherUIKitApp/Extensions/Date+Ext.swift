//
//  Date+Ext.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 31.03.2026.
//

import Foundation

extension Date {

	static func formatTime(epoch: Int) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(epoch))
		return AppDateFormatters.time.string(from: date)
	}

	static func formatHour(epoch: Int) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(epoch))
		return AppDateFormatters.hour.string(from: date)
	}

	static func formatDate(epoch: Int) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(epoch))
		return AppDateFormatters.date.string(from: date)
	}
}
