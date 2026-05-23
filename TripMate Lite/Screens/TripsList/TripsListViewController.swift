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
    
    private var trips: [Trip] = []
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
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
                equalTo: titleLabel.bottomAnchor,
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
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
        guard let mainTabBarController = tabBarController as? MainTabBarController else {
            return
        }
        
        mainTabBarController.openAddTripScreen()
    }
    
    func loadTrips() {
        trips = TripStorage.shared.fetchTrips()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = trips.isEmpty
        
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

extension TripsListViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        trips.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TripTableViewCell.identifier,
            for: indexPath
        ) as? TripTableViewCell
        
        let trip = trips[indexPath.row]
        cell?.configure(with: trip)
        
        return cell ?? UITableViewCell()
    }
}

extension TripsListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let trip = trips[indexPath.row]
        let detailsViewController = TripDetailsViewController(trip: trip)
        
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let trip = trips[indexPath.row]
        
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
            
            TripStorage.shared.deleteTrip(trip)
            
            self.trips.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyState()
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction, editAction]
        )

        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}
