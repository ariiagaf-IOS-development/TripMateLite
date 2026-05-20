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
    }

    private var trips: [Trip] = []
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground
        title = "TripMate"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add, target: self, action: #selector(addTripTapped)
        )
        
        setupTitleLabel()
        setupTableView()
        setupEmptyStateLabel()
        updateEmptyState()
        loadTrips()
    }
    
    private func loadTrips() {
        trips = TripStorage.shared.fetchTrips()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            TripTableViewCell.self,
            forCellReuseIdentifier: TripTableViewCell.identifier
        )
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        
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
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "My Trips"
        titleLabel.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
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
        ])
        
    }
    
    @objc private func addTripTapped() {
        let addTripVC = AddTripViewController()
        
        addTripVC.onTripCreated = { [weak self] trip in
            TripStorage.shared.saveTrip(trip)
            
            self?.trips.append(trip)
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
        
        navigationController?.pushViewController(addTripVC, animated: true)
    }
    
    private func setupEmptyStateLabel() {
        view.addSubview(emptyStateLabel)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No trips yet:(\nTap the + to add your first trip"
        emptyStateLabel.font = .systemFont(ofSize: 20)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            emptyStateLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalPadding
            )
        ])
    }
    
    private func updateEmptyState() {
        let isEmpty = trips.isEmpty
        
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

extension TripsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        let detailsViewController = TripDetailsViewController(trip: trip)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            let trip = self.trips[indexPath.row]
            TripStorage.shared.deleteTrip(trip)
            
            self.trips.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyState()
            
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
