//
//  TripsListViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 14.05.2026.
//

import UIKit

class TripsListViewController: UIViewController {

    private var trips: [Trip] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "My Trips"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add, target: self, action: #selector(addTripTapped)
        )
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func addTripTapped() {
        let addTripVC = AddTripViewController()
        
        addTripVC.onTripCreated = { [weak self] trip in
            self?.trips.append(trip)
            self?.tableView.reloadData()
        }
        
        navigationController?.pushViewController(addTripVC, animated: true)
    }
}

extension TripsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trips.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        let trip = trips[indexPath.row]
        cell.textLabel?.text = trip.basicInfo.destination
        return cell
    }
}
