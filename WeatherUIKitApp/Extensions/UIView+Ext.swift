//
//  UIView+Ext.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 31.03.2026.
//

import UIKit

extension UIView {
	
	func addSubviews(_ views: UIView...) {
		for view in views {
			addSubview(view)
			view.translatesAutoresizingMaskIntoConstraints = false
		}
	}
}
