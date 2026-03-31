//
//  ForecastDayCell.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import UIKit

final class ForecastDayCell: UITableViewCell {

	// MARK: - Public Properties

	static let reuseId = "ForecastDayCell"

	// MARK: - Private Properties

	private let iconView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let dateLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .headline)
		return label
	}()

	private let conditionLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.textColor = .secondaryLabel
		return label
	}()

	private let minMaxLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.textAlignment = .right
		return label
	}()

	private lazy var descriptionStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [
			dateLabel,
			conditionLabel
		])
		stackView.axis = .vertical
		stackView.spacing = 2
		return stackView
	}()

	private lazy var mainStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [
			iconView,
			descriptionStack,
			UIView(),
			minMaxLabel
		])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = 12
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

	func configure(with model: ForecastDayViewData, imageLoader: ImageLoaderServiceProtocol) {
		dateLabel.text = model.date
		conditionLabel.text = model.condition
		minMaxLabel.text = model.minMax
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

private extension ForecastDayCell {

	func setupUI() {
		contentView.addSubviews(mainStack)
		let iconSize: CGFloat = 34
		let mainStackVInset: CGFloat = 12
		let mainStackHInset: CGFloat = 16

		NSLayoutConstraint.activate([
			iconView.widthAnchor.constraint(equalToConstant: iconSize),
			iconView.heightAnchor.constraint(equalToConstant: iconSize),

			mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: mainStackVInset),
			mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainStackHInset),
			mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainStackHInset),
			mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -mainStackVInset)
		])
	}
}
