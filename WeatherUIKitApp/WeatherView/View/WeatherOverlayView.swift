//
//  WeatherOverlayView.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import UIKit

final class WeatherOverlayView: UIView {

	// MARK: - Public Properties

	var onRetry: (() -> Void)?

	// MARK: - Private Properties

	private let spinner = UIActivityIndicatorView(style: .large)

	private let errorLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .center
		label.textColor = .secondaryLabel
		return label
	}()

	private lazy var errorStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [
			errorLabel,
			retryButton
		])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 12
		return stackView
	}()

	private lazy var retryButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Повторить", for: .normal)
		button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		button.addAction(UIAction { [weak self] _ in
			self?.onRetry?()
		}, for: .touchUpInside)
		return button
	}()

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		hide()
	}

	required init?(coder: NSCoder) { nil }

	// MARK: - Public Methods

	func showLoading() {
		isHidden = false
		alpha = 1
		spinner.isHidden = false
		spinner.startAnimating()
		errorStack.isHidden = true
	}

	func showError(message: String) {
		isHidden = false
		alpha = 1
		spinner.stopAnimating()
		spinner.isHidden = true
		errorLabel.text = message
		errorStack.isHidden = false
	}

	func hide() {
		spinner.stopAnimating()
		isHidden = true
		alpha = 0
	}
}

// MARK: - Private Methods

private extension WeatherOverlayView {

	func setupUI() {
		isUserInteractionEnabled = true
		backgroundColor = .systemBackground
		setupSpinner()
		setupError()
	}

	func setupSpinner() {
		addSubviews(spinner)
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	func setupError() {
		addSubviews(errorStack)
		NSLayoutConstraint.activate([
			errorStack.centerXAnchor.constraint(equalTo: centerXAnchor),
			errorStack.centerYAnchor.constraint(equalTo: centerYAnchor),
			errorStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
			errorStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
		])
	}
}
