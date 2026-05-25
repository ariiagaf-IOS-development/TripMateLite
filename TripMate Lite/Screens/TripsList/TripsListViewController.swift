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
    
    private enum ListItem {
        case folder(TripFolder)
        case trip(Trip)
    }
    
    private var filteredTrips: [Trip] = []
    private var folders: [TripFolder] = []
    private var listItems: [ListItem] = []
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
        
        let visibleHeight = tableView.bounds.height - bottomInset

        emptyStateView.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: visibleHeight
        )
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
        
        updateListItems()
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
        
        tableView.register(
            FolderTableViewCell.self,
            forCellReuseIdentifier: FolderTableViewCell.identifier
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
        tableView.backgroundView = emptyStateView
        
        emptyStateView.backgroundColor = .clear
        emptyStateView.isHidden = true
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 14
        
        emptyIconContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        emptyIconContainerView.layer.cornerRadius = Layout.emptyIconContainerSize / 2
        emptyIconContainerView.clipsToBounds = true
        
        emptyIconImageView.image = UIImage(systemName: "ticket")
        emptyIconImageView.tintColor = .systemBlue
        emptyIconImageView.contentMode = .scaleAspectFit
        
        emptyTitleLabel.text = "No upcoming trips"
        emptyTitleLabel.font = .systemFont(
            ofSize: Layout.emptyTitleFontSize,
            weight: .semibold
        )
        emptyTitleLabel.textColor = .label
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.numberOfLines = 0
        
        emptySubtitleLabel.text = "Add your next trip and keep the route, stay, and notes in one place."
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
        
        emptyHintLabel.text = "Tap + to add a trip"
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
        
        emptyStateView.addSubview(contentStackView)
        emptyIconContainerView.addSubview(emptyIconImageView)
        
        contentStackView.addArrangedSubview(emptyIconContainerView)
        contentStackView.addArrangedSubview(emptyTitleLabel)
        contentStackView.addArrangedSubview(emptySubtitleLabel)
        contentStackView.addArrangedSubview(emptyHintView)
        
        emptyHintView.addSubview(emptyHintIconImageView)
        emptyHintView.addSubview(emptyHintLabel)
        emptyHintView.addSubview(emptyHintButton)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyIconContainerView.translatesAutoresizingMaskIntoConstraints = false
        emptyIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyHintView.translatesAutoresizingMaskIntoConstraints = false
        emptyHintIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyHintLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyHintButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            NSLayoutConstraint(
                item: contentStackView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: emptyStateView,
                attribute: .centerY,
                multiplier: 0.78,
                constant: 0
            ),
            contentStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: emptyStateView.leadingAnchor,
                constant: Layout.emptyStateHorizontalPadding
            ),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: emptyStateView.trailingAnchor,
                constant: -Layout.emptyStateHorizontalPadding
            ),
            
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
            
            emptySubtitleLabel.widthAnchor.constraint(
                lessThanOrEqualToConstant: 280
            ),
            
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
        
        showAddOptions()
    }
    
    func showAddOptions() {
        let optionsViewController = AddOptionsViewController()
        
        optionsViewController.modalPresentationStyle = .overFullScreen
        optionsViewController.modalTransitionStyle = .crossDissolve
        
        optionsViewController.onAddTripTapped = {
            NotificationCenter.default.post(name: .openAddTrip, object: nil)
        }
        
        optionsViewController.onCreateFolderTapped = { [weak self] in
            self?.openCreateFolder()
        }
        
        present(optionsViewController, animated: false)
    }
    
    private func openCreateFolder() {
        let createFolderViewController = CreateFolderViewController()
        
        createFolderViewController.onFolderCreated = { [weak self] folder in
            guard let self else {
                return
            }
            
            TripStorage.shared.saveFolder(folder)
            self.loadTrips()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.showToast(
                    "\(folder.name) created",
                    iconName: "folder.fill",
                    tintColor: folder.colorName.folderUIColor
                )
            }
        }
        
        let navigationController = UINavigationController(
            rootViewController: createFolderViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    func loadTrips() {
        trips = TripStorage.shared.fetchTrips()
        folders = TripStorage.shared.fetchFolders()
        applyFilter()
    }
    
    func showToast(
        _ message: String,
        iconName: String = "checkmark.circle.fill",
        tintColor: UIColor = .systemBlue
    ) {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.96)
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.14
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 18
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 16)
        
        let iconContainerView = UIView()
        iconContainerView.backgroundColor = tintColor.withAlphaComponent(0.12)
        iconContainerView.layer.cornerRadius = 16
        iconContainerView.clipsToBounds = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = tintColor
        iconImageView.contentMode = .scaleAspectFit
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .label
        messageLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        messageLabel.numberOfLines = 2
        
        view.addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
            containerView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 20
            ),
            containerView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -20
            ),
            
            iconContainerView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 14
            ),
            iconContainerView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: 12
            ),
            iconContainerView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -12
            ),
            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalToConstant: 32),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            messageLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor,
                constant: 10
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -16
            ),
            messageLabel.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor)
        ])
        
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut]
        ) {
            containerView.alpha = 1
            containerView.transform = .identity
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.5,
            options: [.curveEaseIn]
        ) {
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(translationX: 0, y: 12)
        } completion: { _ in
            containerView.removeFromSuperview()
        }
    }
    
    private func updateListItems() {
        let searchText = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""
        
        let visibleFolders: [TripFolder]
        let visibleTrips: [Trip]
        
        if searchText.isEmpty {
            visibleFolders = folders.filter { folder in
                shouldShowFolder(folder)
            }
            
            visibleTrips = filteredTrips.filter { trip in
                trip.folderID == nil
            }
        } else {
            visibleFolders = folders.filter { folder in
                folder.name.lowercased().contains(searchText)
            }
            
            let tripsFromMatchedFolders = visibleFolders.flatMap { folder in
                tripsForCurrentFilter(in: folder)
            }
            
            let allSearchTrips = filteredTrips + tripsFromMatchedFolders
            
            visibleTrips = Array(
                Dictionary(grouping: allSearchTrips, by: { $0.id })
                    .compactMap { $0.value.first }
            )
            .sorted {
                $0.basicInfo.startDate < $1.basicInfo.startDate
            }
        }
        
        let folderItems = visibleFolders.map { folder in
            ListItem.folder(folder)
        }
        
        let tripItems = visibleTrips.map { trip in
            ListItem.trip(trip)
        }
        
        listItems = folderItems + tripItems
    }
    
    private func tripsForCurrentFilter(in folder: TripFolder) -> [Trip] {
        let today = Calendar.current.startOfDay(for: Date())
        
        let folderTrips = trips.filter { trip in
            trip.folderID == folder.id
        }
        
        switch selectedFilter {
        case .upcoming:
            return folderTrips.filter {
                Calendar.current.startOfDay(for: $0.basicInfo.endDate) >= today
            }
            
        case .past:
            return folderTrips.filter {
                Calendar.current.startOfDay(for: $0.basicInfo.endDate) < today
            }
        }
    }
    
    private func folderTripCounts(_ folder: TripFolder) -> (upcoming: Int, past: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        
        let folderTrips = trips.filter { trip in
            trip.folderID == folder.id
        }
        
        let upcomingCount = folderTrips.filter { trip in
            Calendar.current.startOfDay(for: trip.basicInfo.endDate) >= today
        }.count
        
        let pastCount = folderTrips.filter { trip in
            Calendar.current.startOfDay(for: trip.basicInfo.endDate) < today
        }.count
        
        return (upcomingCount, pastCount)
    }
    
    private func shouldShowFolder(_ folder: TripFolder) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        let folderTrips = trips.filter { trip in
            trip.folderID == folder.id
        }
        
        if folderTrips.isEmpty {
            return true
        }
        
        let hasUpcomingTrip = folderTrips.contains { trip in
            Calendar.current.startOfDay(for: trip.basicInfo.endDate) >= today
        }
        
        switch selectedFilter {
        case .upcoming:
            return hasUpcomingTrip
            
        case .past:
            return true
        }
    }
    
    private func folderForTrip(_ trip: Trip) -> TripFolder? {
        guard let folderID = trip.folderID else {
            return nil
        }
        
        return folders.first { folder in
            folder.id == folderID
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = listItems.isEmpty
        let searchText = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isSearching = !searchText.isEmpty
        
        tableView.backgroundView = isEmpty ? emptyStateView : nil
        tableView.isHidden = false
        tableView.isUserInteractionEnabled = true
        
        emptyStateView.isHidden = !isEmpty
        emptyStateView.isUserInteractionEnabled = isEmpty
        
        if isSearching {
            emptyIconImageView.image = UIImage(systemName: "magnifyingglass")
            emptyTitleLabel.text = "No results found"
            emptySubtitleLabel.text = "Try searching by destination, route, hotel, or note."
            emptyHintIconImageView.image = UIImage(systemName: "xmark.circle.fill")
            emptyHintLabel.text = "Clear search"
            return
        }
        
        switch selectedFilter {
        case .upcoming:
            emptyIconImageView.image = UIImage(systemName: "airplane.departure")
            emptyTitleLabel.text = "No upcoming trips"
            emptySubtitleLabel.text = "Add your next trip and keep the route, stay, notes, and packing checklist in one place."
            emptyHintIconImageView.image = UIImage(systemName: "plus.circle.fill")
            emptyHintLabel.text = "Tap + to add a trip"
            
        case .past:
            emptyIconImageView.image = UIImage(systemName: "clock.arrow.circlepath")
            emptyTitleLabel.text = "No past trips"
            emptySubtitleLabel.text = "Completed trips will appear here after their end date."
            emptyHintIconImageView.image = UIImage(systemName: "plus.circle.fill")
            emptyHintLabel.text = "Tap + to add a trip"
        }
    }
}

extension TripsListViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        listItems.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = listItems[indexPath.row]
        
        switch item {
        case .folder(let folder):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FolderTableViewCell.identifier,
                for: indexPath
            ) as? FolderTableViewCell
            
            let counts = folderTripCounts(folder)
            cell?.configure(
                with: folder,
                upcomingCount: counts.upcoming,
                pastCount: counts.past
            )
            
            return cell ?? UITableViewCell()
            
        case .trip(let trip):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TripTableViewCell.identifier,
                for: indexPath
            ) as? TripTableViewCell
            
            let searchText = searchController.searchBar.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if !searchText.isEmpty {
                cell?.configure(with: trip, folder: folderForTrip(trip))
            } else {
                cell?.configure(with: trip)
            }
            
            return cell ?? UITableViewCell()
        }
    }
}

extension TripsListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let item = listItems[indexPath.row]
        
        switch item {
        case .folder(let folder):
            let folderTripsViewController = FolderTripsViewController(folder: folder)
            navigationController?.pushViewController(folderTripsViewController, animated: true)
            
        case .trip(let trip):
            let detailsViewController = TripDetailsViewController(trip: trip)
            let navigationController = UINavigationController(rootViewController: detailsViewController)
            
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let item = listItems[indexPath.row]
        
        switch item {
        case .folder(let folder):
            return makeFolderSwipeActions(for: folder)
            
        case .trip(let trip):
            return makeTripSwipeActions(for: trip)
        }
    }
    
    private func makeTripSwipeActions(for trip: Trip) -> UISwipeActionsConfiguration {
        
        let moveAction = UIContextualAction(
            style: .normal,
            title: "Move"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            self.showMoveTripOptions(for: trip)
            completion(true)
        }

        moveAction.backgroundColor = .systemPurple
        moveAction.image = UIImage(systemName: "folder")
        
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

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.showToast(
                            "Trip deleted",
                            iconName: "trash.fill",
                            tintColor: .systemRed
                        )
                    }
                }
            )
            
            self.present(alert, animated: true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction, editAction, moveAction]
        )
        
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    private func showMoveTripOptions(for trip: Trip) {
        let folders = TripStorage.shared.fetchFolders()
        
        let alert = UIAlertController(
            title: "Move trip",
            message: "Choose where to move this trip.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: "No Folder",
                style: .default
            ) { [weak self] _ in
                TripStorage.shared.moveTrip(trip, to: nil)
                self?.loadTrips()
                self?.showToast(
                    "Moved to No Folder",
                    iconName: "tray.fill",
                    tintColor: .systemGray
                )
            }
        )
        
        for folder in folders {
            alert.addAction(
                UIAlertAction(
                    title: folder.name,
                    style: .default
                ) { [weak self] _ in
                    TripStorage.shared.moveTrip(trip, to: folder.id)
                    self?.loadTrips()
                    self?.showToast(
                        "Moved to \(folder.name)",
                        iconName: "folder.fill",
                        tintColor: folder.colorName.folderUIColor
                    )
                }
            )
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        present(alert, animated: true)
    }
    
    private func makeFolderSwipeActions(for folder: TripFolder) -> UISwipeActionsConfiguration {
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            let editFolderViewController = CreateFolderViewController(folder: folder)

            editFolderViewController.onFolderUpdated = { [weak self] updatedFolder in
                TripStorage.shared.updateFolder(updatedFolder)
                self?.loadTrips()
            }

            let navigationController = UINavigationController(
                rootViewController: editFolderViewController
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
                title: "Delete folder?",
                message: "Trips inside this folder will not be deleted. They will move back to the main list.",
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
                    TripStorage.shared.removeFolderFromTrips(folderID: folder.id)
                    TripStorage.shared.deleteFolder(folder)
                    self.loadTrips()
                    completion(true)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.showToast(
                            "Folder deleted",
                            iconName: "trash.fill",
                            tintColor: .systemRed
                        )
                    }
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
