//
//  CurrentWeatherCell.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import UIKit

final class CurrentWeatherCell: UITableViewCell {

	// MARK: - Public Properties

	static let reuseId = "CurrentWeatherCell"

	// MARK: - Private Properties

	private let iconView: UIImageView = {
		let iconView = UIImageView()
		iconView.contentMode = .scaleAspectFit
		iconView.tintColor = .label
		return iconView
	}()

	private let tempLabel: UILabel = {
		let tempLabel = UILabel()
		tempLabel.font = .systemFont(ofSize: 44, weight: .bold)
		tempLabel.textColor = .label
		return tempLabel
	}()

	private let conditionLabel: UILabel = {
		let conditionLabel = UILabel()
		conditionLabel.font = .preferredFont(forTextStyle: .headline)
		conditionLabel.textColor = .secondaryLabel
		return conditionLabel
	}()

	private let detailsLabel: UILabel = {
		let detailsLabel = UILabel()
		detailsLabel.font = .preferredFont(forTextStyle: .subheadline)
		detailsLabel.textColor = .secondaryLabel
		detailsLabel.numberOfLines = 0
		return detailsLabel
	}()

	private let updatedLabel: UILabel = {
		let updatedLabel = UILabel()
		updatedLabel.font = .preferredFont(forTextStyle: .caption1)
		updatedLabel.textColor = .tertiaryLabel
		return updatedLabel
	}()

	private lazy var tempStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [tempLabel, conditionLabel])
		stackView.axis = .vertical
		stackView.spacing = 2
		return stackView
	}()

	private lazy var mainInfoStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [
			iconView,
			tempStack
		])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = 12
		return stackView
	}()

	private lazy var mainStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [
			mainInfoStack,
			detailsLabel,
			updatedLabel
		])
		stackView.axis = .vertical
		stackView.spacing = 8
		return stackView
	}()

	// MARK: - Lifecycle

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupUI()
	}

	required init?(coder: NSCoder) { nil }

	// MARK: - Public Methods

	func configure(with model: CurrentWeatherViewData, imageLoader: ImageLoaderServiceProtocol) {
		tempLabel.text = model.temperature
		conditionLabel.text = model.condition
		detailsLabel.text = "\(model.feelsLike) · \(model.wind) · \(model.humidity)"
		updatedLabel.text = model.updatedAt
		iconView.image = UIImage(systemName: "cloud")

		Task { [weak self] in
			let image = await imageLoader.load(url: model.iconURL)
			guard let image else { return }
			await MainActor.run {
				self?.iconView.image = image
			}
		}
	}
}

// MARK: - Private Methods

private extension CurrentWeatherCell {

	func setupUI() {
		contentView.addSubviews(mainStack)

		NSLayoutConstraint.activate([
			iconView.widthAnchor.constraint(equalToConstant: 56),
			iconView.heightAnchor.constraint(equalToConstant: 56),

			mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}
}
