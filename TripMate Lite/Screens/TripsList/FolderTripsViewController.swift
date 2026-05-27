//
//  FolderTripsViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class FolderTripsViewController: UIViewController {
    
    private var folder: TripFolder
    private var trips: [Trip] = []
    private var hasAppeared = false
        
    private let tableView = UITableView()
    
    private let headerView = UIView()
    private let folderIconContainerView = UIView()
    private let folderIconImageView = UIImageView()
    private let folderNameLabel = UILabel()
    private let folderCountLabel = UILabel()
    
    private enum Layout {
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
    
    private let emptyStateView = UIView()
    private let emptyIconContainerView = UIView()
    private let emptyIconImageView = UIImageView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    private let emptyHintView = UIView()
    private let emptyHintIconImageView = UIImageView()
    private let emptyHintLabel = UILabel()
    private let emptyHintButton = UIButton(type: .system)
    
    init(folder: TripFolder) {
        self.folder = folder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        title = folder.name
        
        setupEditButton()
        setupHeaderView()
        setupTableView()
        setupEmptyStateView()
        loadTrips()
    }
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        
        headerView.addSubview(folderIconContainerView)
        folderIconContainerView.addSubview(folderIconImageView)
        headerView.addSubview(folderNameLabel)
        headerView.addSubview(folderCountLabel)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        folderIconContainerView.translatesAutoresizingMaskIntoConstraints = false
        folderIconImageView.translatesAutoresizingMaskIntoConstraints = false
        folderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        folderCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let folderColor = folder.colorName.folderUIColor
        
        folderIconContainerView.backgroundColor = folderColor.withAlphaComponent(0.12)
        folderIconContainerView.layer.cornerRadius = 24
        folderIconContainerView.clipsToBounds = true
        
        folderIconImageView.image = UIImage(systemName: "folder.fill")
        folderIconImageView.tintColor = folderColor
        folderIconImageView.contentMode = .scaleAspectFit
        
        folderNameLabel.text = folder.name
        folderNameLabel.font = .systemFont(ofSize: 32, weight: .bold)
        folderNameLabel.textColor = .label
        folderNameLabel.numberOfLines = 1
        folderNameLabel.adjustsFontSizeToFitWidth = true
        folderNameLabel.minimumScaleFactor = 0.75
        
        folderCountLabel.font = .systemFont(ofSize: 15, weight: .medium)
        folderCountLabel.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 64),
            
            folderIconContainerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            folderIconContainerView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            folderIconContainerView.widthAnchor.constraint(equalToConstant: 48),
            folderIconContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            folderIconImageView.centerXAnchor.constraint(equalTo: folderIconContainerView.centerXAnchor),
            folderIconImageView.centerYAnchor.constraint(equalTo: folderIconContainerView.centerYAnchor),
            folderIconImageView.widthAnchor.constraint(equalToConstant: 26),
            folderIconImageView.heightAnchor.constraint(equalToConstant: 26),
            
            folderNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 2),
            folderNameLabel.leadingAnchor.constraint(
                equalTo: folderIconContainerView.trailingAnchor,
                constant: 14
            ),
            folderNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            folderCountLabel.topAnchor.constraint(equalTo: folderNameLabel.bottomAnchor, constant: 4),
            folderCountLabel.leadingAnchor.constraint(equalTo: folderNameLabel.leadingAnchor),
            folderCountLabel.trailingAnchor.constraint(equalTo: folderNameLabel.trailingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasAppeared {
            loadTrips()
        } else {
            hasAppeared = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomInset = view.safeAreaInsets.bottom
        let visibleHeight = tableView.bounds.height - bottomInset
        
        emptyStateView.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: visibleHeight
        )
    }
    
    private func showToast(
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
    
    @objc private func editFolderTapped() {
        let editFolderViewController = CreateFolderViewController(folder: folder)
        
        editFolderViewController.onFolderUpdated = { [weak self] updatedFolder in
            guard let self else {
                return
            }
            
            TripStorage.shared.updateFolder(updatedFolder)
            self.folder = updatedFolder
            self.title = updatedFolder.name
            self.folderNameLabel.text = updatedFolder.name

            let folderColor = updatedFolder.colorName.folderUIColor
            self.folderIconContainerView.backgroundColor = folderColor.withAlphaComponent(0.12)
            self.folderIconImageView.tintColor = folderColor
            self.updateEmptyStateAppearance()
            self.loadTrips()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.showToast(
                    "Folder updated",
                    iconName: "checkmark.circle.fill",
                    tintColor: folderColor
                )
            }
        }
        
        editFolderViewController.onFolderDeleted = { [weak self] folder in
            TripStorage.shared.deleteTripFolder(folder)
            self?.navigationController?.popViewController(animated: true)
        }
        
        let navigationController = UINavigationController(
            rootViewController: editFolderViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editFolderTapped)
        )
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
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
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
        
        let folderColor = folder.colorName.folderUIColor
        
        emptyIconContainerView.backgroundColor = folderColor.withAlphaComponent(0.10)
        emptyIconContainerView.layer.cornerRadius = Layout.emptyIconContainerSize / 2
        emptyIconContainerView.clipsToBounds = true
        
        emptyIconImageView.image = UIImage(systemName: "folder.fill")
        emptyIconImageView.tintColor = folderColor
        emptyIconImageView.contentMode = .scaleAspectFit
        
        emptyTitleLabel.text = "No trips in \(folder.name) yet"
        emptyTitleLabel.font = .systemFont(
            ofSize: Layout.emptyTitleFontSize,
            weight: .semibold
        )
        emptyTitleLabel.textColor = .label
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.numberOfLines = 0
        
        emptySubtitleLabel.text = "Add a trip to \(folder.name) and keep everything organized in one place."
        emptySubtitleLabel.font = .systemFont(ofSize: Layout.emptySubtitleFontSize)
        emptySubtitleLabel.textColor = .secondaryLabel
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0
        
        emptyHintView.backgroundColor = folderColor.withAlphaComponent(0.10)
        emptyHintView.layer.cornerRadius = Layout.emptyHintCornerRadius
        emptyHintView.clipsToBounds = true
        emptyHintView.isUserInteractionEnabled = true
        
        emptyHintIconImageView.image = UIImage(systemName: "plus.circle.fill")
        emptyHintIconImageView.tintColor = folderColor
        emptyHintIconImageView.contentMode = .scaleAspectFit
        
        emptyHintLabel.text = "Tap + to add a trip"
        emptyHintLabel.font = .systemFont(
            ofSize: Layout.emptyHintFontSize,
            weight: .medium
        )
        emptyHintLabel.textColor = folderColor
        
        emptyHintButton.backgroundColor = .clear
        emptyHintButton.addTarget(
            self,
            action: #selector(addTripTapped),
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
    
    private func loadTrips() {
        trips = TripStorage.shared.fetchTripsForList(in: folder.id)
        
        tableView.reloadData()

        let isEmpty = trips.isEmpty
        tableView.backgroundView = isEmpty ? emptyStateView : nil
        emptyStateView.isHidden = !isEmpty
        emptyStateView.isUserInteractionEnabled = isEmpty
        
        let tripWord = trips.count == 1 ? "trip" : "trips"
        folderCountLabel.text = "\(trips.count) \(tripWord) inside"
    }
    
    private func updateEmptyStateAppearance() {
        let folderColor = folder.colorName.folderUIColor
        
        emptyIconContainerView.backgroundColor = folderColor.withAlphaComponent(0.10)
        emptyIconImageView.tintColor = folderColor
        emptyTitleLabel.text = "No trips in \(folder.name) yet"
        emptySubtitleLabel.text = "Add a trip to \(folder.name) and keep everything organized in one place."
        emptyHintView.backgroundColor = folderColor.withAlphaComponent(0.10)
        emptyHintIconImageView.tintColor = folderColor
        emptyHintLabel.textColor = folderColor
    }
    
    @objc func addTripTapped() {
        let addTripViewController = AddTripViewController(folderID: folder.id)
        
        addTripViewController.onTripCreated = { [weak self] trip in
            guard let self else {
                return
            }
            
            TripStorage.shared.saveTrip(trip)
            self.loadTrips()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.showToast(
                    "Saved to \(self.folder.name)",
                    iconName: "folder.fill",
                    tintColor: self.folder.colorName.folderUIColor
                )
            }
        }
        
        let navigationController = UINavigationController(
            rootViewController: addTripViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func showMoveTripOptions(for trip: Trip) {
        let folders = TripStorage.shared.fetchFolders()
        
        let folderPickerViewController = FolderPickerViewController(
            folders: folders,
            selectedFolderID: trip.folderID
        )
        
        folderPickerViewController.onFolderSelected = { [weak self] folderID in
            guard let self else {
                return
            }
            
            TripStorage.shared.moveTrip(trip, to: folderID)
            self.loadTrips()
            
            if let folderID,
               let selectedFolder = folders.first(where: { $0.id == folderID }) {
                self.showToast(
                    "Moved to \(selectedFolder.name)",
                    iconName: "folder.fill",
                    tintColor: selectedFolder.colorName.folderUIColor
                )
            } else {
                self.showToast(
                    "Moved to No Folder",
                    iconName: "tray.fill",
                    tintColor: .systemGray
                )
            }
        }
        
        present(folderPickerViewController, animated: true)
    }
}

extension FolderTripsViewController: UITableViewDataSource {
    
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
        
        cell?.configure(with: trips[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
}

extension FolderTripsViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let trip = trips[indexPath.row]
        let detailsViewController = TripDetailsViewController(trip: trip)
        
        let navigationController = UINavigationController(
            rootViewController: detailsViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
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
            
            let fullTrip = TripStorage.shared.fetchTrip(id: trip.id) ?? trip
            let editViewController = AddTripViewController(trip: fullTrip)
            
            editViewController.onTripUpdated = { [weak self] updatedTrip in
                guard let self else {
                    return
                }
                
                TripStorage.shared.updateTrip(updatedTrip)
                self.loadTrips()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    self.showToast(
                        "Trip updated",
                        iconName: "checkmark.circle.fill",
                        tintColor: self.folder.colorName.folderUIColor
                    )
                }
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
}
