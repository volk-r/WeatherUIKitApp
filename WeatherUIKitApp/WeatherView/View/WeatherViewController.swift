//
//  WeatherViewController.swift
//  WeatherUIKitApp
//
//  Created by Roman Romanov on 30.03.2026.
//

import UIKit

final class WeatherViewController: UIViewController {

	// MARK: - Private Properties

	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.dataSource = self
		tableView.estimatedRowHeight = 100
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(
			CurrentWeatherCell.self,
			forCellReuseIdentifier: CurrentWeatherCell.reuseId
		)
		tableView.register(
			HourlyForecastCell.self,
			forCellReuseIdentifier: HourlyForecastCell.reuseId
		)
		tableView.register(
			ForecastDayCell.self,
			forCellReuseIdentifier: ForecastDayCell.reuseId
		)
		return tableView
	}()

	private let overlay = WeatherOverlayView()

	private let viewModel: WeatherViewModel
	private let imageLoader: ImageLoaderServiceProtocol
	private var model: WeatherScreenModel?

	// MARK: - Init

	init(
		viewModel: WeatherViewModel,
		imageLoader: ImageLoaderServiceProtocol
	) {
		self.viewModel = viewModel
		self.imageLoader = imageLoader
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) { nil }

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()

		viewModel.refresh()
	}
}

// MARK: - Private Methods

private extension WeatherViewController {

	func setupUI() {
		title = "Погода"
		view.backgroundColor = .systemBackground
		
		setupTable()
		setupOverlay()
	}

	func setupTable() {
		view.addSubviews(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	func setupOverlay() {
		overlay.onRetry = { [weak self] in self?.viewModel.refresh() }
		view.addSubviews(overlay)
		NSLayoutConstraint.activate([
			overlay.topAnchor.constraint(equalTo: view.topAnchor),
			overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	func bindViewModel() {
		viewModel.onStateChange = { [weak self] state in
			guard let self else { return }
			switch state {
			case .loading:
				self.overlay.showLoading()
			case .error(let message):
				self.overlay.showError(message: message)
			case .loaded(let model):
				self.model = model
				self.overlay.hide()
				self.tableView.reloadData()
				self.title = model.current.city
			}
		}
	}
}

// MARK: - UITableViewDataSource

extension WeatherViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		WeatherSection.allCases.count
	}

	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		guard let model else { return 0 }
		switch WeatherSection(rawValue: section)! {
		case .current:
			return 1
		case .hourly:
			return model.hourly.isEmpty ? 0 : 1
		case .forecast:
			return model.forecast3Days.count
		}
	}

	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		guard let model, let section = WeatherSection(rawValue: indexPath.section) else {
			return UITableViewCell()
		}

		switch section {
		case .current:
			let cell = tableView.dequeueReusableCell(withIdentifier: CurrentWeatherCell.reuseId, for: indexPath) as! CurrentWeatherCell
			cell.configure(with: model.current, imageLoader: imageLoader)
			return cell
		case .hourly:
			let cell = tableView.dequeueReusableCell(withIdentifier: HourlyForecastCell.reuseId, for: indexPath) as! HourlyForecastCell
			cell.configure(items: model.hourly, imageLoader: imageLoader)
			return cell
		case .forecast:
			let cell = tableView.dequeueReusableCell(withIdentifier: ForecastDayCell.reuseId, for: indexPath) as! ForecastDayCell
			cell.configure(with: model.forecast3Days[indexPath.row], imageLoader: imageLoader)
			return cell
		}
	}

	func tableView(
		_ tableView: UITableView,
		titleForHeaderInSection section: Int
	) -> String? {
		guard let section = WeatherSection(rawValue: section) else { return nil }
		switch section {
		case .current:
			return nil
		case .hourly:
			return "Почасовой прогноз"
		case .forecast:
			return "Прогноз на 3 дня"
		}
	}
}

// MARK: - WeatherSection

private enum WeatherSection: Int, CaseIterable {
	case current
	case hourly
	case forecast
}
