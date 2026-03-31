//
//  HourlyForecastCell.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import UIKit

final class HourlyForecastCell: UITableViewCell {

	// MARK: - Public Properties
	
	static let reuseId = "HourlyForecastCell"

	// MARK: - Private Properties

	private var items: [HourlyWeatherViewData] = []
	private var imageLoader: ImageLoaderServiceProtocol?

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = .clear
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(
			HourlyItemCell.self,
			forCellWithReuseIdentifier: HourlyItemCell.reuseId
		)
		return collectionView
	}()

	// MARK: - Lifecycle

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupUI()
	}

	required init?(coder: NSCoder) { nil }

	// MARK: - Public Methods

	func configure(items: [HourlyWeatherViewData], imageLoader: ImageLoaderServiceProtocol) {
		self.items = items
		self.imageLoader = imageLoader
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource

extension HourlyForecastCell: UICollectionViewDataSource {

	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		items.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		guard
			let imageLoader,
			let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: HourlyItemCell.reuseId,
				for: indexPath
			) as? HourlyItemCell
		else { return UICollectionViewCell() }
		cell.configure(with: items[indexPath.item], imageLoader: imageLoader)
		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HourlyForecastCell: UICollectionViewDelegateFlowLayout {

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		CGSize(width: 72, height: 110)
	}
}

// MARK: - Private Methods

private extension HourlyForecastCell {

	func setupUI() {
		contentView.addSubviews(collectionView)
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
			collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110)
		])
	}
}

// MARK: - HourlyItemCell

private final class HourlyItemCell: UICollectionViewCell {

	static let reuseId = "HourlyItemCell"

	private let timeLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		label.textColor = .secondaryLabel
		return label
	}()

	private let iconView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let tempLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.textAlignment = .center
		return label
	}()

	private lazy var mainStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [
			timeLabel,
			iconView,
			tempLabel
		])
		stack.axis = .vertical
		stack.alignment = .fill
		stack.spacing = 6
		return stack
	}()

	// MARK: - Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) { nil }

	// MARK: - Public Methods

	func configure(with model: HourlyWeatherViewData, imageLoader: ImageLoaderServiceProtocol) {
		timeLabel.text = model.time
		tempLabel.text = model.temperature
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

private extension HourlyItemCell {

	func setupUI() {
		contentView.backgroundColor = .secondarySystemBackground
		contentView.layer.cornerRadius = 12
		contentView.layer.masksToBounds = true
		contentView.addSubviews(mainStack)

		let mainStackVInset: CGFloat = 10
		let mainStackHInset: CGFloat = 8

		NSLayoutConstraint.activate([
			iconView.heightAnchor.constraint(equalToConstant: 28),

			mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: mainStackVInset),
			mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainStackHInset),
			mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainStackHInset),
			mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -mainStackVInset)
		])
	}
}
