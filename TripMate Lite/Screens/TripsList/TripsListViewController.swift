//
//  TripsListViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 14.05.2026.
//

import UIKit

final class TripsListViewController: UIViewController {
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 24
        static let titleToTableSpacing: CGFloat = 24
        static let titleFontSize: CGFloat = 32
        
        static let emptyStateHorizontalPadding: CGFloat = 40
        static let emptyIconContainerSize: CGFloat = 80
        static let emptyIconSize: CGFloat = 40
        static let emptyTitleFontSize: CGFloat = 22
        static let emptySubtitleFontSize: CGFloat = 15
        static let emptyHintFontSize: CGFloat = 15
        static let emptyHintHorizontalPadding: CGFloat = 16
        static let emptyHintVerticalPadding: CGFloat = 8
        static let emptyHintCornerRadius: CGFloat = 18
    }
    
    private enum TripsFilter {
        case upcoming
        case past
    }
    
    private var trips: [Trip] = []
    private var filteredTrips: [Trip] = []
    private var selectedFilter: TripsFilter = .upcoming
    
    private let titleLabel = UILabel()
    private let filterSegmentedControl = UISegmentedControl(items: ["Upcoming", "Past"])
    private let tableView = UITableView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateView = UIView()
    private let emptyIconContainerView = UIView()
    private let emptyIconImageView = UIImageView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    private let emptyHintView = UIView()
    private let emptyHintIconImageView = UIImageView()
    private let emptyHintLabel = UILabel()
    private let emptyHintButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupTitleLabel()
        setupSearchController()
        setupFilterSegmentedControl()
        setupTableView()
        setupEmptyStateView()
        loadTrips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTrips()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        let bottomInset = tabBarHeight + view.safeAreaInsets.bottom
        
        tableView.contentInset.bottom = bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search destination, route, hotel"
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.font = .systemFont(ofSize: 14, weight: .regular)
        searchTextField.layer.cornerRadius = 14
        searchTextField.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            searchTextField.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    
    
    private func setupFilterSegmentedControl() {
        view.addSubview(filterSegmentedControl)
        
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.selectedSegmentTintColor = .systemBlue
        
        filterSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ],
            for: .selected
        )
        
        filterSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ],
            for: .normal
        )
        
        filterSegmentedControl.addTarget(
            self,
            action: #selector(filterChanged),
            for: .valueChanged
        )
        
        NSLayoutConstraint.activate([
            filterSegmentedControl.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 18
            ),
            filterSegmentedControl.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            filterSegmentedControl.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func filterChanged() {
        selectedFilter = filterSegmentedControl.selectedSegmentIndex == 0
        ? .upcoming
        : .past
        
        applyFilter()
    }

    private func applyFilter() {
        let today = Calendar.current.startOfDay(for: Date())
        
        let tripsByDate: [Trip]
        
        switch selectedFilter {
        case .upcoming:
            tripsByDate = trips.filter {
                Calendar.current.startOfDay(for: $0.basicInfo.endDate) >= today
            }
            
        case .past:
            tripsByDate = trips.filter {
                Calendar.current.startOfDay(for: $0.basicInfo.endDate) < today
            }
        }
        
        let searchText = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""
        
        if searchText.isEmpty {
            filteredTrips = tripsByDate
        } else {
            filteredTrips = tripsByDate.filter { trip in
                let destination = trip.basicInfo.destination.lowercased()
                let note = trip.basicInfo.note.lowercased()
                let hotel = trip.hotelDetails.hotelName.lowercased()
                let address = trip.hotelDetails.address.lowercased()
                
                let routeText = trip.routeSteps
                    .map {
                        "\($0.transportType) \($0.from) \($0.to) \($0.company) \($0.bookingNumber)"
                    }
                    .joined(separator: " ")
                    .lowercased()
                
                return destination.contains(searchText)
                || note.contains(searchText)
                || hotel.contains(searchText)
                || address.contains(searchText)
                || routeText.contains(searchText)
            }
        }
        
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "My Trips"
        titleLabel.font = .systemFont(
            ofSize: Layout.titleFontSize,
            weight: .bold
        )
        titleLabel.textColor = .label
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Layout.topPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalPadding
            )
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            TripTableViewCell.self,
            forCellReuseIdentifier: TripTableViewCell.identifier
        )
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: filterSegmentedControl.bottomAnchor,
                constant: Layout.titleToTableSpacing
            ),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)
        
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyIconContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        emptyIconContainerView.layer.cornerRadius = Layout.emptyIconContainerSize / 2
        emptyIconContainerView.clipsToBounds = true
        
        emptyIconImageView.image = UIImage(systemName: "ticket")
        emptyIconImageView.tintColor = .systemBlue
        emptyIconImageView.contentMode = .scaleAspectFit
        
        emptyTitleLabel.text = "No trips yet"
        emptyTitleLabel.font = .systemFont(
            ofSize: Layout.emptyTitleFontSize,
            weight: .semibold
        )
        emptyTitleLabel.textColor = .label
        emptyTitleLabel.textAlignment = .center
        
        emptySubtitleLabel.text = "Add your first trip to keep everything in one place."
        emptySubtitleLabel.font = .systemFont(ofSize: Layout.emptySubtitleFontSize)
        emptySubtitleLabel.textColor = .secondaryLabel
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0
        
        emptyHintView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        emptyHintView.layer.cornerRadius = Layout.emptyHintCornerRadius
        emptyHintView.clipsToBounds = true
        emptyHintView.isUserInteractionEnabled = true
        
        emptyHintIconImageView.image = UIImage(systemName: "arrow.down")
        emptyHintIconImageView.tintColor = .systemBlue
        emptyHintIconImageView.contentMode = .scaleAspectFit
        
        emptyHintLabel.text = "Tap + to start"
        emptyHintLabel.font = .systemFont(
            ofSize: Layout.emptyHintFontSize,
            weight: .medium
        )
        emptyHintLabel.textColor = .systemBlue
        
        emptyHintButton.backgroundColor = .clear
        emptyHintButton.addTarget(
            self,
            action: #selector(emptyStateTapped),
            for: .touchUpInside
        )
        
        emptyStateView.addSubview(emptyIconContainerView)
        emptyIconContainerView.addSubview(emptyIconImageView)
        
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptySubtitleLabel)
        emptyStateView.addSubview(emptyHintView)
        
        emptyHintView.addSubview(emptyHintIconImageView)
        emptyHintView.addSubview(emptyHintLabel)
        emptyHintView.addSubview(emptyHintButton)
        
        emptyIconContainerView.translatesAutoresizingMaskIntoConstraints = false
        emptyIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyHintView.translatesAutoresizingMaskIntoConstraints = false
        emptyHintIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyHintLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyHintButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.emptyStateHorizontalPadding
            ),
            emptyStateView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.emptyStateHorizontalPadding
            ),
            emptyStateView.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor,
                constant: -60
            ),
            
            emptyIconContainerView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIconContainerView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIconContainerView.widthAnchor.constraint(
                equalToConstant: Layout.emptyIconContainerSize
            ),
            emptyIconContainerView.heightAnchor.constraint(
                equalToConstant: Layout.emptyIconContainerSize
            ),
            
            emptyIconImageView.centerXAnchor.constraint(
                equalTo: emptyIconContainerView.centerXAnchor
            ),
            emptyIconImageView.centerYAnchor.constraint(
                equalTo: emptyIconContainerView.centerYAnchor
            ),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: Layout.emptyIconSize),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: Layout.emptyIconSize),
            
            emptyTitleLabel.topAnchor.constraint(
                equalTo: emptyIconContainerView.bottomAnchor,
                constant: 20
            ),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptySubtitleLabel.topAnchor.constraint(
                equalTo: emptyTitleLabel.bottomAnchor,
                constant: 8
            ),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyHintView.topAnchor.constraint(
                equalTo: emptySubtitleLabel.bottomAnchor,
                constant: 24
            ),
            emptyHintView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyHintView.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            emptyHintIconImageView.leadingAnchor.constraint(
                equalTo: emptyHintView.leadingAnchor,
                constant: Layout.emptyHintHorizontalPadding
            ),
            emptyHintIconImageView.centerYAnchor.constraint(equalTo: emptyHintView.centerYAnchor),
            emptyHintIconImageView.widthAnchor.constraint(equalToConstant: 16),
            emptyHintIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            emptyHintLabel.leadingAnchor.constraint(
                equalTo: emptyHintIconImageView.trailingAnchor,
                constant: 8
            ),
            emptyHintLabel.trailingAnchor.constraint(
                equalTo: emptyHintView.trailingAnchor,
                constant: -Layout.emptyHintHorizontalPadding
            ),
            emptyHintLabel.topAnchor.constraint(
                equalTo: emptyHintView.topAnchor,
                constant: Layout.emptyHintVerticalPadding
            ),
            emptyHintLabel.bottomAnchor.constraint(
                equalTo: emptyHintView.bottomAnchor,
                constant: -Layout.emptyHintVerticalPadding
            ),
            
            emptyHintButton.topAnchor.constraint(equalTo: emptyHintView.topAnchor),
            emptyHintButton.leadingAnchor.constraint(equalTo: emptyHintView.leadingAnchor),
            emptyHintButton.trailingAnchor.constraint(equalTo: emptyHintView.trailingAnchor),
            emptyHintButton.bottomAnchor.constraint(equalTo: emptyHintView.bottomAnchor)
        ])
    }
    
    @objc private func emptyStateTapped() {
        let searchText = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !searchText.isEmpty {
            searchController.searchBar.text = ""
            searchController.isActive = false
            applyFilter()
            return
        }
        
        NotificationCenter.default.post(name: .openAddTrip, object: nil)
    }
    
    func loadTrips() {
        trips = TripStorage.shared.fetchTrips()
        applyFilter()
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredTrips.isEmpty
        let searchText = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isSearching = !searchText.isEmpty
        
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        if isSearching {
            emptyTitleLabel.text = "No results found"
            emptySubtitleLabel.text = "Try another destination, route, hotel, or note."
            emptyHintLabel.text = "Clear search"
            return
        }
        
        switch selectedFilter {
        case .upcoming:
            emptyTitleLabel.text = "No upcoming trips"
            emptySubtitleLabel.text = "Add your next trip and keep the route, stay, and notes in one place."
            emptyHintLabel.text = "Tap + to add a trip"
            
        case .past:
            emptyTitleLabel.text = "No past trips"
            emptySubtitleLabel.text = "Completed trips will appear here after their end date."
            emptyHintLabel.text = "Tap + to add a trip"
        }
    }
}

extension TripsListViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        filteredTrips.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TripTableViewCell.identifier,
            for: indexPath
        ) as? TripTableViewCell
        
        let trip = filteredTrips[indexPath.row]
        cell?.configure(with: trip)
        
        return cell ?? UITableViewCell()
    }
}

extension TripsListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let trip = filteredTrips[indexPath.row]
        let detailsViewController = TripDetailsViewController(trip: trip)
        
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let trip = filteredTrips[indexPath.row]
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            let editViewController = AddTripViewController(trip: trip)
            
            editViewController.onTripUpdated = { [weak self] updatedTrip in
                guard let self else {
                    return
                }
                
                TripStorage.shared.updateTrip(updatedTrip)
                self.loadTrips()
            }
            
            let navigationController = UINavigationController(
                rootViewController: editViewController
            )
            
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
            
            completion(true)
        }
        
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            let alert = UIAlertController(
                title: "Delete trip?",
                message: "This trip will be permanently removed.",
                preferredStyle: .alert
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel
                ) { _ in
                    completion(false)
                }
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "Delete",
                    style: .destructive
                ) { _ in
                    TripStorage.shared.deleteTrip(trip)
                    self.loadTrips()
                    completion(true)
                }
            )
            
            self.present(alert, animated: true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction, editAction]
        )

        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}

extension TripsListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        applyFilter()
    }
}

extension Notification.Name {
    static let openAddTrip = Notification.Name("openAddTrip")
}
