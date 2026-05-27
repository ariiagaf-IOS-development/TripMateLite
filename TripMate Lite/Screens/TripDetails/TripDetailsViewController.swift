//
//  TripDetailsViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class TripDetailsViewController: UIViewController {
    
    private var trip: Trip
        
    private let activitiesListStackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let folderBadgeView = UIView()
    private let folderBadgeIconView = UIImageView()
    private let folderBadgeLabel = UILabel()
    
    private let folderBadgeActionLabel = UILabel()
        
    private let checklistTableView = UITableView()
    private var checklistTableHeightConstraint: NSLayoutConstraint?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 24
        
        static let titleFontSize: CGFloat = 32
        static let dateFontSize: CGFloat = 16
        static let titleToDateSpacing: CGFloat = 6
        static let headerToContentSpacing: CGFloat = 32
        
        static let stackSpacing: CGFloat = 28
        static let cardPadding: CGFloat = 20
        static let cardCornerRadius: CGFloat = 20
        static let cardInnerSpacing: CGFloat = 18
        
        static let sectionTitleFontSize: CGFloat = 15
        static let cardTitleFontSize: CGFloat = 19
        static let labelFontSize: CGFloat = 11
        static let valueFontSize: CGFloat = 15
        static let noteFontSize: CGFloat = 16
        
        static let iconSize: CGFloat = 22
    }
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFullTrip()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupEditButton()
        setupCloseButton()
        setupHeader()
        setupFolderBadge()
        setupScrollView()
        setupStackView()
        setupChecklistTableView()
        setupDetailsContent()
    }
    
    private func loadFullTrip() {
        trip = TripStorage.shared.fetchTrip(id: trip.id) ?? trip
    }
    
    private func setupChecklistTableView() {
        checklistTableView.backgroundColor = .clear
        checklistTableView.separatorStyle = .none
        checklistTableView.showsVerticalScrollIndicator = false
        checklistTableView.isScrollEnabled = false
        checklistTableView.rowHeight = 46
        
        checklistTableView.dataSource = self
        checklistTableView.delegate = self
        
        checklistTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "ChecklistCell"
        )
    }
    
    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }
    
    @objc private func deleteTripTapped() {
        confirmDeleteTrip()
    }
    
    private func showMoveTripOptions() {
        let folders = TripStorage.shared.fetchFolders()
        
        let folderPickerViewController = FolderPickerViewController(
            folders: folders,
            selectedFolderID: trip.folderID
        )
        
        folderPickerViewController.onFolderSelected = { [weak self] folderID in
            guard let self else {
                return
            }
            
            TripStorage.shared.moveTrip(self.trip, to: folderID)
            self.loadFullTrip()
            self.reloadDetails()
            
            if let folderID,
               let folder = folders.first(where: { $0.id == folderID }) {
                self.showToast(
                    "Moved to \(folder.name)",
                    iconName: "folder.fill",
                    tintColor: folder.colorName.folderUIColor
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
    
    private func confirmDeleteTrip() {
        let alert = UIAlertController(
            title: "Delete trip?",
            message: "This trip will be permanently removed.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                guard let self else {
                    return
                }
                
                TripStorage.shared.deleteTrip(self.trip)
                self.dismiss(animated: true)
            }
        )
        
        present(alert, animated: true)
    }
    
    private func setupFolderBadge() {
        view.addSubview(folderBadgeView)
        
        folderBadgeView.addSubview(folderBadgeIconView)
        folderBadgeView.addSubview(folderBadgeLabel)
        folderBadgeView.addSubview(folderBadgeActionLabel)
        
        folderBadgeView.translatesAutoresizingMaskIntoConstraints = false
        folderBadgeIconView.translatesAutoresizingMaskIntoConstraints = false
        folderBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        folderBadgeActionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        folderBadgeView.layer.cornerRadius = 16
        folderBadgeView.clipsToBounds = true
        
        folderBadgeView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(folderBadgeTapped)
        )

        folderBadgeView.addGestureRecognizer(tapGesture)
        
        folderBadgeIconView.image = UIImage(systemName: "folder.fill")
        folderBadgeIconView.contentMode = .scaleAspectFit
        
        folderBadgeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        folderBadgeLabel.numberOfLines = 1
        
        folderBadgeActionLabel.text = "Change"
        folderBadgeActionLabel.font = .systemFont(ofSize: 12, weight: .bold)
        folderBadgeActionLabel.textAlignment = .center
        folderBadgeActionLabel.layer.cornerRadius = 10
        folderBadgeActionLabel.clipsToBounds = true
        
        updateFolderBadge()
        
        NSLayoutConstraint.activate([
            folderBadgeView.topAnchor.constraint(
                equalTo: dateLabel.bottomAnchor,
                constant: 14
            ),
            folderBadgeView.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            folderBadgeView.heightAnchor.constraint(equalToConstant: 32),
            
            folderBadgeIconView.leadingAnchor.constraint(
                equalTo: folderBadgeView.leadingAnchor,
                constant: 12
            ),
            folderBadgeIconView.centerYAnchor.constraint(equalTo: folderBadgeView.centerYAnchor),
            folderBadgeIconView.widthAnchor.constraint(equalToConstant: 16),
            folderBadgeIconView.heightAnchor.constraint(equalToConstant: 16),
            
            folderBadgeLabel.leadingAnchor.constraint(
                equalTo: folderBadgeIconView.trailingAnchor,
                constant: 8
            ),
            folderBadgeLabel.trailingAnchor.constraint(
                equalTo: folderBadgeActionLabel.leadingAnchor,
                constant: -8
            ),
            folderBadgeLabel.centerYAnchor.constraint(equalTo: folderBadgeView.centerYAnchor),

            folderBadgeActionLabel.trailingAnchor.constraint(
                equalTo: folderBadgeView.trailingAnchor,
                constant: -8
            ),
            folderBadgeActionLabel.centerYAnchor.constraint(equalTo: folderBadgeView.centerYAnchor),
            folderBadgeActionLabel.widthAnchor.constraint(equalToConstant: 58),
            folderBadgeActionLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func folderBadgeTapped() {
        showMoveTripOptions()
    }
    
    private func updateFolderBadge() {
        guard let folderID = trip.folderID else {
            folderBadgeLabel.text = "No Folder"
            folderBadgeLabel.textColor = .secondaryLabel
            folderBadgeIconView.tintColor = .secondaryLabel
            folderBadgeActionLabel.textColor = .secondaryLabel
            folderBadgeActionLabel.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.45)
            folderBadgeView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.7)
            return
        }
        
        let folders = TripStorage.shared.fetchFolders()
        let folder = folders.first { $0.id == folderID }
        
        let folderName = folder?.name ?? "Unknown Folder"
        let folderColor = folder?.colorName.folderUIColor ?? .systemBlue
        
        folderBadgeLabel.text = folderName
        folderBadgeLabel.textColor = folderColor
        folderBadgeIconView.tintColor = folderColor
        folderBadgeActionLabel.textColor = folderColor
        folderBadgeActionLabel.backgroundColor = folderColor.withAlphaComponent(0.16)
        folderBadgeView.backgroundColor = folderColor.withAlphaComponent(0.12)
    }
    
    @objc private func editButtonTapped() {
        let editViewController = AddTripViewController(trip: trip)
        
        editViewController.onTripUpdated = { [weak self] updatedTrip in
            guard let self else {
                return
            }
            
            TripStorage.shared.updateTrip(updatedTrip)
            self.trip = updatedTrip
            self.reloadDetails()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.showToast(
                    "Trip updated",
                    iconName: "checkmark.circle.fill",
                    tintColor: .systemBlue
                )
            }
        }
        
        editViewController.onTripDeleted = { [weak self] deletedTrip in
            TripStorage.shared.deleteTrip(deletedTrip)
            self?.dismiss(animated: true)
        }
        
        let navigationController = UINavigationController(
            rootViewController: editViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func reloadDetails() {
        titleLabel.text = trip.basicInfo.destination
        
        let startDate = trip.basicInfo.startDate.tripDateString
        let endDate = trip.basicInfo.endDate.tripDateString
        dateLabel.text = "\(startDate) — \(endDate)"
        
        updateFolderBadge()
        
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        setupDetailsContent()
    }
    
    private func setupHeader() {
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = trip.basicInfo.destination
        titleLabel.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        
        let startDate = trip.basicInfo.startDate.tripDateString
        let endDate = trip.basicInfo.endDate.tripDateString
        
        dateLabel.text = "\(startDate) — \(endDate)"
        dateLabel.font = .systemFont(ofSize: Layout.dateFontSize, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        
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
            ),
            
            dateLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Layout.titleToDateSpacing
            ),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: folderBadgeView.bottomAnchor,
                constant: Layout.headerToContentSpacing
            ),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupStackView() {
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Layout.stackSpacing
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.bottomPadding
            )
        ])
    }
    
    private func setupDetailsContent() {
        addRouteSection()
        addReturnRouteSection()
        addHotelSection()
        addActivitiesSection()
        addNoteSectionIfNeeded()
        addChecklistSection()
    }
    
    private func addRouteSection() {
        
        let routeSteps = trip.routeSteps
        
        let hasRouteData = routeSteps.contains { step in
            !step.transportType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.bookingNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        if !hasRouteData {
            let sectionStack = makeSectionStack(
                iconName: "arrow.triangle.branch",
                title: "Route"
            )
            
            let card = makeCardView()
            
            let emptyLabel = UILabel()
            emptyLabel.text = "Not specified"
            emptyLabel.font = .systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.numberOfLines = 0
            
            card.addArrangedSubview(emptyLabel)
            sectionStack.addArrangedSubview(card)
            stackView.addArrangedSubview(sectionStack)
            
            return
        }
        
        let sectionStack = makeSectionStack(
            iconName: routeSteps.count > 1 ? "arrow.triangle.branch" : trip.transportDetails.iconName,
            title: routeSteps.count > 1 ? "Route Plan" : trip.transportDetails.displayType
        )
        
        let card = makeCardView()
        
        if routeSteps.count > 1 {
            for (index, step) in routeSteps.enumerated() {
                let stepTitle = makeInfoBlock(
                    title: "Route Step \(index + 1)",
                    value: step.displayType,
                    useMutedBackground: true
                )
                
                let routeLineView = makeRouteLineView(
                    from: step.from,
                    to: step.to,
                    iconName: step.iconName
                )
                
                let routeRow = makeTwoColumnRow(
                    leftTitle: "From",
                    leftValue: step.from,
                    rightTitle: "To",
                    rightValue: step.to
                )
                
                let placesRow = makePlacesRowIfNeeded(
                    departurePlace: step.departurePlace,
                    arrivalPlace: step.arrivalPlace
                )
                
                let dateRow = makeTwoColumnRow(
                    leftTitle: "Departure",
                    leftValue: step.departureDate.tripDateTimeString,
                    rightTitle: "Arrival",
                    rightValue: step.arrivalDate.tripDateTimeString
                )
                
                let detailsRow = makeTwoColumnRow(
                    leftTitle: "Company",
                    leftValue: step.company,
                    rightTitle: "Booking No.",
                    rightValue: step.bookingNumber
                )
                
                card.addArrangedSubview(stepTitle)
                card.addArrangedSubview(routeLineView)
                card.addArrangedSubview(routeRow)

                if let placesRow {
                    card.addArrangedSubview(placesRow)
                }

                card.addArrangedSubview(dateRow)
                card.addArrangedSubview(detailsRow)
                
                if index < routeSteps.count - 1 {
                    card.addArrangedSubview(makeSeparator())
                }
            }
        } else {
            let routeLineView = makeRouteLineView(
                from: trip.transportDetails.from,
                to: trip.transportDetails.to,
                iconName: trip.transportDetails.iconName
            )

            card.addArrangedSubview(routeLineView)
            card.addArrangedSubview(makeSeparator())
            
            let routeRow = makeTwoColumnRow(
                leftTitle: "From",
                leftValue: trip.transportDetails.from,
                rightTitle: "To",
                rightValue: trip.transportDetails.to
            )
            
            let placesRow = makePlacesRowIfNeeded(
                departurePlace: trip.transportDetails.departurePlace,
                arrivalPlace: trip.transportDetails.arrivalPlace
            )
            
            let dateRow = makeTwoColumnRow(
                leftTitle: "Departure",
                leftValue: trip.transportDetails.departureDate.tripDateTimeString,
                rightTitle: "Arrival",
                rightValue: trip.transportDetails.arrivalDate.tripDateTimeString
            )
            
            let detailsRow = makeTwoColumnRow(
                leftTitle: "Company",
                leftValue: trip.transportDetails.company,
                rightTitle: "Booking No.",
                rightValue: trip.transportDetails.bookingNumber
            )
            
            card.addArrangedSubview(routeRow)

            if let placesRow {
                card.addArrangedSubview(placesRow)
            }

            card.addArrangedSubview(dateRow)
            card.addArrangedSubview(detailsRow)
        }
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addReturnRouteSection() {
        guard trip.hasReturnTicket, !trip.returnRouteSteps.isEmpty else {
            return
        }
        
        let sectionStack = makeSectionStack(
            iconName: trip.returnRouteSteps.count > 1
            ? "arrow.triangle.branch"
            : trip.returnRouteSteps.first?.iconName ?? "arrow.uturn.backward",
            title: trip.returnRouteSteps.count > 1 ? "Return Route" : "Return Ticket"
        )
        
        let card = makeCardView()
        
        if trip.returnRouteSteps.count > 1 {
            for (index, step) in trip.returnRouteSteps.enumerated() {
                let stepTitle = makeInfoBlock(
                    title: "Return Step \(index + 1)",
                    value: step.displayType,
                    useMutedBackground: true
                )
                
                let routeLineView = makeRouteLineView(
                    from: step.from,
                    to: step.to,
                    iconName: step.iconName
                )
                
                let routeRow = makeTwoColumnRow(
                    leftTitle: "From",
                    leftValue: step.from,
                    rightTitle: "To",
                    rightValue: step.to
                )
                
                let placesRow = makePlacesRowIfNeeded(
                    departurePlace: step.departurePlace,
                    arrivalPlace: step.arrivalPlace
                )
                
                let dateRow = makeTwoColumnRow(
                    leftTitle: "Departure",
                    leftValue: step.departureDate.tripDateTimeString,
                    rightTitle: "Arrival",
                    rightValue: step.arrivalDate.tripDateTimeString
                )
                
                let detailsRow = makeTwoColumnRow(
                    leftTitle: "Company",
                    leftValue: step.company,
                    rightTitle: "Booking No.",
                    rightValue: step.bookingNumber
                )
                
                card.addArrangedSubview(stepTitle)
                card.addArrangedSubview(routeLineView)
                card.addArrangedSubview(routeRow)

                if let placesRow {
                    card.addArrangedSubview(placesRow)
                }

                card.addArrangedSubview(dateRow)
                card.addArrangedSubview(detailsRow)
                
                if index < trip.returnRouteSteps.count - 1 {
                    card.addArrangedSubview(makeSeparator())
                }
            }
        } else if let step = trip.returnRouteSteps.first {
            let routeLineView = makeRouteLineView(
                from: step.from,
                to: step.to,
                iconName: step.iconName
            )
            
            card.addArrangedSubview(routeLineView)
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftTitle: "From",
                    leftValue: step.from,
                    rightTitle: "To",
                    rightValue: step.to
                )
            )

            if let placesRow = makePlacesRowIfNeeded(
                departurePlace: step.departurePlace,
                arrivalPlace: step.arrivalPlace
            ) {
                card.addArrangedSubview(placesRow)
            }

            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftTitle: "Departure",
                    leftValue: step.departureDate.tripDateTimeString,
                    rightTitle: "Arrival",
                    rightValue: step.arrivalDate.tripDateTimeString
                )
            )
            
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftTitle: "Company",
                    leftValue: step.company,
                    rightTitle: "Booking No.",
                    rightValue: step.bookingNumber
                )
            )
        }
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addHotelSection() {
        let sectionStack = makeSectionStack(
            iconName: "building.2.fill",
            title: "Hotel"
        )
        
        let card = makeCardView()
        
        if !trip.hasHotelDetails {
            let emptyLabel = UILabel()
            emptyLabel.text = "Not specified"
            emptyLabel.font = .systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.numberOfLines = 0
            
            card.addArrangedSubview(emptyLabel)
            sectionStack.addArrangedSubview(card)
            stackView.addArrangedSubview(sectionStack)
            return
        }
        
        let hotelName = trip.hotelDetails.hotelName.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = trip.hotelDetails.address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !hotelName.isEmpty {
            let hotelNameLabel = UILabel()
            hotelNameLabel.text = hotelName
            hotelNameLabel.font = .systemFont(ofSize: Layout.cardTitleFontSize, weight: .bold)
            hotelNameLabel.textColor = .label
            hotelNameLabel.numberOfLines = 0
            card.addArrangedSubview(hotelNameLabel)
        }
        
        if !address.isEmpty {
            let addressStack = UIStackView()
            addressStack.axis = .horizontal
            addressStack.spacing = 6
            addressStack.alignment = .top
            
            let iconImageView = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
            iconImageView.tintColor = .secondaryLabel
            iconImageView.contentMode = .scaleAspectFit
            
            let addressLabel = UILabel()
            addressLabel.text = address
            addressLabel.font = .systemFont(ofSize: 14)
            addressLabel.textColor = .secondaryLabel
            addressLabel.numberOfLines = 0
            
            addressStack.addArrangedSubview(iconImageView)
            addressStack.addArrangedSubview(addressLabel)
            
            iconImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            iconImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            
            card.addArrangedSubview(addressStack)
        }
        
        if trip.hasHotelDates {
            card.addArrangedSubview(makeSeparator())
            
            let datesRow = makeTwoColumnRow(
                leftTitle: "Check-in",
                leftValue: trip.hotelDetails.checkInDate.tripDateTimeString,
                rightTitle: "Check-out",
                rightValue: trip.hotelDetails.checkOutDate.tripDateTimeString,
                useMutedBackground: true
            )
            
            card.addArrangedSubview(datesRow)
        }
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addNoteSectionIfNeeded() {
        let note = trip.basicInfo.note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !note.isEmpty else {
            return
        }
        
        let sectionStack = makeSectionStack(
            iconName: "note.text",
            title: "Note"
        )
        
        let card = makeCardView()
        
        let noteLabel = UILabel()
        noteLabel.text = note
        noteLabel.font = .systemFont(ofSize: Layout.noteFontSize)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0
        
        card.addArrangedSubview(noteLabel)
        sectionStack.addArrangedSubview(card)
        
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addActivitiesSection() {
        let sectionStack = makeSectionStack(
            iconName: "map.fill",
            title: "Activities"
        )
        
        let card = makeCardView()
        
        if trip.activities.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No activities yet"
            emptyLabel.font = .systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.numberOfLines = 0
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Add day trips, excursions, tours, or places you want to visit."
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.numberOfLines = 0
            
            card.addArrangedSubview(emptyLabel)
            card.addArrangedSubview(subtitleLabel)
        } else {
            activitiesListStackView.axis = .vertical
            activitiesListStackView.spacing = 12
            activitiesListStackView.alignment = .fill
            activitiesListStackView.distribution = .fill
            
            activitiesListStackView.arrangedSubviews.forEach { view in
                activitiesListStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for activity in trip.activities {
                let activityCard = makeActivityPreviewCard(activity)
                activitiesListStackView.addArrangedSubview(activityCard)
            }
            
            card.addArrangedSubview(activitiesListStackView)
        }
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(makeAddActivityButton())
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func makeActivityPreviewCard(_ activity: TripActivity) -> UIView {
        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 6
        card.layoutMargins = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        card.isLayoutMarginsRelativeArrangement = true
        
        card.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.65)
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        
        card.isUserInteractionEnabled = true
        card.tag = activity.id.hashValue
        
        let titleLabel = UILabel()
        titleLabel.text = activity.title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        let dateLabel = UILabel()
        if activity.hasTime {
            dateLabel.text = "\(activity.date.tripDateString) · \(activity.time.tripTimeString)"
        } else {
            dateLabel.text = activity.date.tripDateString
        }
        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 0
        
        let locationLabel = UILabel()
        let location = activity.location.trimmingCharacters(in: .whitespacesAndNewlines)
        locationLabel.text = location.isEmpty ? "No location" : location
        locationLabel.font = .systemFont(ofSize: 14, weight: .medium)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 0
        
        card.addArrangedSubview(titleLabel)
        card.addArrangedSubview(dateLabel)
        card.addArrangedSubview(locationLabel)
        
        if activity.hasRouteDetails {
            let route = activity.routeDetails
            let from = route.from.trimmingCharacters(in: .whitespacesAndNewlines)
            let to = route.to.trimmingCharacters(in: .whitespacesAndNewlines)
            let transport = route.displayType
            
            let routeLabel = UILabel()
            if from.isEmpty && to.isEmpty {
                routeLabel.text = transport
            } else {
                routeLabel.text = "\(transport) · \(from) → \(to)"
            }
            routeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            routeLabel.textColor = .label
            routeLabel.numberOfLines = 0
            
            card.addArrangedSubview(routeLabel)
        }
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(activityPreviewCardTapped(_:))
        )
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
    @objc private func activityPreviewCardTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        
        guard let activity = trip.activities.first(where: { $0.id.hashValue == view.tag }) else {
            return
        }
        
        openActivityDetails(activity)
    }
    
    private func openActivityDetails(_ activity: TripActivity) {
        let activityDetailsViewController = ActivityDetailsViewController(activity: activity)
        
        activityDetailsViewController.onActivityUpdated = { [weak self] updatedActivity in
            guard let self else {
                return
            }
            
            updateActivity(updatedActivity)
        }
        
        activityDetailsViewController.onActivityDeleted = { [weak self] deletedActivity in
            guard let self else {
                return
            }
            
            deleteActivity(deletedActivity)
        }
        
        let navigationController = UINavigationController(
            rootViewController: activityDetailsViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func confirmDeleteActivity(_ activity: TripActivity) {
        let alert = UIAlertController(
            title: "Delete activity?",
            message: "This activity will be removed from your trip.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                self?.deleteActivity(activity)
            }
        )
        
        present(alert, animated: true)
    }
    
    private func deleteActivity(_ activity: TripActivity) {
        
        let updatedActivities = trip.activities.filter { $0.id != activity.id }
        
        let updatedTrip = Trip(
            id: trip.id,
            folderID: trip.folderID,
            basicInfo: trip.basicInfo,
            transportDetails: trip.transportDetails,
            routeSteps: trip.routeSteps,
            hotelDetails: trip.hotelDetails,
            hasHotelDetails: trip.hasHotelDetails,
            hasHotelDates: trip.hasHotelDates,
            checklistItems: trip.checklistItems,
            hasReturnTicket: trip.hasReturnTicket,
            returnRouteSteps: trip.returnRouteSteps,
            activities: updatedActivities
        )
        
        TripStorage.shared.updateTrip(updatedTrip)
        trip = updatedTrip
        reloadDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.showToast(
                "Activity deleted",
                iconName: "trash.fill",
                tintColor: .systemRed
            )
        }
    }
    
    private func updateActivity(_ updatedActivity: TripActivity) {
        let updatedActivities = trip.activities.map { activity in
            if activity.id == updatedActivity.id {
                return updatedActivity
            }
            
            return activity
        }
        .sorted { $0.date < $1.date }
        
        let updatedTrip = Trip(
            id: trip.id,
            folderID: trip.folderID,
            basicInfo: trip.basicInfo,
            transportDetails: trip.transportDetails,
            routeSteps: trip.routeSteps,
            hotelDetails: trip.hotelDetails,
            hasHotelDetails: trip.hasHotelDetails,
            hasHotelDates: trip.hasHotelDates,
            checklistItems: trip.checklistItems,
            hasReturnTicket: trip.hasReturnTicket,
            returnRouteSteps: trip.returnRouteSteps,
            activities: updatedActivities
        )
        
        TripStorage.shared.updateTrip(updatedTrip)
        trip = updatedTrip
        reloadDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.showToast(
                "Activity updated",
                iconName: "checkmark.circle.fill",
                tintColor: .systemBlue
            )
        }
    }
    
    private func addChecklistSection() {
        let sectionStack = makeSectionStack(
            iconName: "checklist",
            title: "Packing Checklist"
        )
        
        let card = makeCardView()
        
        if trip.checklistItems.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No items yet"
            emptyLabel.font = .systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.numberOfLines = 0
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Add things you do not want to forget."
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.numberOfLines = 0
            
            card.addArrangedSubview(emptyLabel)
            card.addArrangedSubview(subtitleLabel)
        } else {
            checklistTableView.reloadData()
            
            checklistTableHeightConstraint?.isActive = false
            checklistTableHeightConstraint = checklistTableView.heightAnchor.constraint(
                equalToConstant: CGFloat(trip.checklistItems.count) * 46
            )
            checklistTableHeightConstraint?.isActive = true
            
            card.addArrangedSubview(checklistTableView)
        }
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(makeAddChecklistItemButton())
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addChecklistItem(title: String) {
        let newItem = ChecklistItem(
            id: UUID(),
            title: title,
            isCompleted: false
        )
        
        updateChecklistItems(trip.checklistItems + [newItem])
    }
    
    @objc private func addChecklistItemTapped() {
        let inputViewController = ChecklistItemInputViewController()
        
        inputViewController.onItemAdded = { [weak self] title in
            self?.addChecklistItem(title: title)
        }
        
        present(inputViewController, animated: true)
    }
    
    private func updateChecklistItems(_ items: [ChecklistItem]) {
        let sortedItems = items.sorted { first, second in
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted && second.isCompleted
            }
            
            return first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
        }
        
        let updatedTrip = Trip(
            id: trip.id,
            folderID: trip.folderID,
            basicInfo: trip.basicInfo,
            transportDetails: trip.transportDetails,
            routeSteps: trip.routeSteps,
            hotelDetails: trip.hotelDetails,
            hasHotelDetails: trip.hasHotelDetails,
            hasHotelDates: trip.hasHotelDates,
            checklistItems: sortedItems,
            hasReturnTicket: trip.hasReturnTicket,
            returnRouteSteps: trip.returnRouteSteps,
            activities: trip.activities
        )
        
        TripStorage.shared.updateTrip(updatedTrip)
        trip = updatedTrip
        reloadDetails()
    }
    
    private func deleteChecklistItem(_ item: ChecklistItem) {
        let updatedItems = trip.checklistItems.filter { $0.id != item.id }
        
        updateChecklistItems(updatedItems)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showToast(
                "Checklist item deleted",
                iconName: "trash.fill",
                tintColor: .systemRed
            )
        }
    }
    
    private func makeAddChecklistItemButton() -> UIView {
        let container = UIView()
        
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Add checklist item"
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        button.configuration = configuration
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        button.addTarget(
            self,
            action: #selector(addChecklistItemTapped),
            for: .touchUpInside
        )
        
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    private func makeAddActivityButton() -> UIView {
        let container = UIView()
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Add activity"
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        button.configuration = configuration
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        button.addTarget(
            self,
            action: #selector(addActivityTapped),
            for: .touchUpInside
        )
        
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    @objc private func addActivityTapped() {
        let addActivityViewController = AddActivityViewController()
        
        addActivityViewController.onActivityCreated = { [weak self] activity in
            guard let self else {
                return
            }
            
            let updatedActivities = (self.trip.activities + [activity])
                .sorted { $0.date < $1.date }
            
            let updatedTrip = Trip(
                id: self.trip.id,
                folderID: self.trip.folderID,
                basicInfo: self.trip.basicInfo,
                transportDetails: self.trip.transportDetails,
                routeSteps: self.trip.routeSteps,
                hotelDetails: self.trip.hotelDetails,
                hasHotelDetails: self.trip.hasHotelDetails,
                hasHotelDates: self.trip.hasHotelDates,
                checklistItems: self.trip.checklistItems,
                hasReturnTicket: self.trip.hasReturnTicket,
                returnRouteSteps: self.trip.returnRouteSteps,
                activities: updatedActivities
            )
            
            TripStorage.shared.updateTrip(updatedTrip)
            self.trip = updatedTrip
            self.reloadDetails()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.showToast(
                    "Activity added",
                    iconName: "map.fill",
                    tintColor: .systemBlue
                )
            }
        }
        
        let navigationController = UINavigationController(
            rootViewController: addActivityViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func makeSectionStack(iconName: String, title: String) -> UIStackView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 12
        
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: Layout.sectionTitleFontSize, weight: .bold)
        titleLabel.textColor = .label
        
        headerStack.addArrangedSubview(iconImageView)
        headerStack.addArrangedSubview(titleLabel)
        
        iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize).isActive = true
        
        sectionStack.addArrangedSubview(headerStack)
        
        return sectionStack
    }
    
    private func makeCardView() -> UIStackView {
        let card = UIStackView()
        
        card.axis = .vertical
        card.spacing = Layout.cardInnerSpacing
        card.layoutMargins = UIEdgeInsets(
            top: Layout.cardPadding,
            left: Layout.cardPadding,
            bottom: Layout.cardPadding,
            right: Layout.cardPadding
        )
        card.isLayoutMarginsRelativeArrangement = true
        card.applyCardStyle()
        
        return card
    }
    
    private func makeTwoColumnRow(
        leftTitle: String,
        leftValue: String,
        rightTitle: String,
        rightValue: String,
        useMutedBackground: Bool = false
    ) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.distribution = .fillEqually
        
        let leftBlock = makeInfoBlock(
            title: leftTitle,
            value: leftValue,
            useMutedBackground: useMutedBackground
        )
        
        let rightBlock = makeInfoBlock(
            title: rightTitle,
            value: rightValue,
            useMutedBackground: useMutedBackground
        )
        
        rowStack.addArrangedSubview(leftBlock)
        rowStack.addArrangedSubview(rightBlock)
        
        return rowStack
    }
    
    private func makePlacesRowIfNeeded(
        departurePlace: String,
        arrivalPlace: String
    ) -> UIView? {
        let departure = departurePlace.trimmingCharacters(in: .whitespacesAndNewlines)
        let arrival = arrivalPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !departure.isEmpty || !arrival.isEmpty else {
            return nil
        }
        
        return makeTwoColumnRow(
            leftTitle: "From place",
            leftValue: departure.isEmpty ? "Not specified" : departure,
            rightTitle: "To place",
            rightValue: arrival.isEmpty ? "Not specified" : arrival,
            useMutedBackground: true
        )
    }
    
    private func makeInfoBlock(
        title: String,
        value: String,
        useMutedBackground: Bool
    ) -> UIView {
        let container = UIView()
        
        if useMutedBackground {
            container.backgroundColor = UIColor.systemGray6
            container.layer.cornerRadius = 12
            container.clipsToBounds = true
        }
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: Layout.labelFontSize, weight: .bold)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not specified" : value
        valueLabel.font = .systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
        
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = useMutedBackground ? 12 : 0
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding)
        ])
        
        return container
    }
    
    private func makeRouteLineView(
        from: String,
        to: String,
        iconName: String
    ) -> UIView {
        let container = UIView()
        
        let fromLabel = UILabel()
        fromLabel.text = from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "From" : from
        fromLabel.font = .systemFont(ofSize: 18, weight: .bold)
        fromLabel.textColor = .label
        fromLabel.numberOfLines = 2
        fromLabel.textAlignment = .left
        fromLabel.adjustsFontSizeToFitWidth = true
        fromLabel.minimumScaleFactor = 0.75
        
        let toLabel = UILabel()
        toLabel.text = to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "To" : to
        toLabel.font = .systemFont(ofSize: 18, weight: .bold)
        toLabel.textColor = .label
        toLabel.numberOfLines = 2
        toLabel.textAlignment = .right
        toLabel.adjustsFontSizeToFitWidth = true
        toLabel.minimumScaleFactor = 0.75
        
        let lineView = UIView()
        lineView.backgroundColor = .systemGray5
        
        let iconBackgroundView = UIView()
        iconBackgroundView.backgroundColor = .cardBackground
        iconBackgroundView.layer.cornerRadius = 14
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        iconBackgroundView.addSubview(iconImageView)
        container.addSubview(fromLabel)
        container.addSubview(lineView)
        container.addSubview(iconBackgroundView)
        container.addSubview(toLabel)
        
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            fromLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            fromLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            fromLabel.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.30),
            
            toLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            toLabel.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.30),
            
            lineView.leadingAnchor.constraint(equalTo: fromLabel.trailingAnchor, constant: 10),
            lineView.trailingAnchor.constraint(equalTo: toLabel.leadingAnchor, constant: -10),
            lineView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            iconBackgroundView.centerXAnchor.constraint(equalTo: lineView.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraint(equalTo: lineView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 28),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 28),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
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
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
}

extension TripDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        if tableView == checklistTableView {
            return trip.checklistItems.count
        }
        
        return 0
    }
    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 46
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        if tableView == checklistTableView {
            return 46
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if tableView == checklistTableView {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistCell",
                for: indexPath
            )
            
            cell.contentConfiguration = nil
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            let item = trip.checklistItems[indexPath.row]
            
            let iconImageView = UIImageView()
            iconImageView.image = UIImage(
                systemName: item.isCompleted ? "checkmark.circle.fill" : "circle"
            )
            iconImageView.tintColor = item.isCompleted ? .systemBlue : .secondaryLabel
            iconImageView.contentMode = .scaleAspectFit
            
            let titleLabel = UILabel()
            
            let attributes: [NSAttributedString.Key: Any]
            
            if item.isCompleted {
                attributes = [
                    .font: UIFont.systemFont(
                        ofSize: Layout.valueFontSize,
                        weight: .semibold
                    ),
                    .foregroundColor: UIColor.secondaryLabel,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            } else {
                attributes = [
                    .font: UIFont.systemFont(
                        ofSize: Layout.valueFontSize,
                        weight: .semibold
                    ),
                    .foregroundColor: UIColor.label
                ]
            }
            
            titleLabel.attributedText = NSAttributedString(
                string: item.title,
                attributes: attributes
            )
            titleLabel.numberOfLines = 1
            
            cell.contentView.addSubview(iconImageView)
            cell.contentView.addSubview(titleLabel)
            
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                iconImageView.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor,
                    constant: 0
                ),
                iconImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 22),
                iconImageView.heightAnchor.constraint(equalToConstant: 22),
                
                titleLabel.leadingAnchor.constraint(
                    equalTo: iconImageView.trailingAnchor,
                    constant: 10
                ),
                titleLabel.trailingAnchor.constraint(
                    equalTo: cell.contentView.trailingAnchor,
                    constant: -4
                ),
                titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        if #available(iOS 14.0, *) {
            cell.backgroundConfiguration = .clear()
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        if tableView == checklistTableView {
            let item = trip.checklistItems[indexPath.row]
            
            let updatedItems = trip.checklistItems.map { checklistItem in
                if checklistItem.id == item.id {
                    return ChecklistItem(
                        id: checklistItem.id,
                        title: checklistItem.title,
                        isCompleted: !checklistItem.isCompleted
                    )
                }
                
                return checklistItem
            }
            
            updateChecklistItems(updatedItems)
            return
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        guard tableView == checklistTableView else {
            return nil
        }
        
        let item = trip.checklistItems[indexPath.row]
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil
        ) { [weak self] _, _, completion in
            self?.deleteChecklistItem(item)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction]
        )
        
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

extension TransportSegment {
    
    var displayType: String {
        let type = transportType.trimmingCharacters(in: .whitespacesAndNewlines)
        return type.isEmpty ? "Route" : type
    }
    
    var iconName: String {
        let type = transportType.lowercased()
        
        if type.contains("plane") || type.contains("flight") || type.contains("air") {
            return "airplane"
        } else if type.contains("train") {
            return "train.side.front.car"
        } else if type.contains("bus") {
            return "bus.fill"
        } else if type.contains("car") || type.contains("taxi") {
            return "car.fill"
        } else if type.contains("ferry") || type.contains("boat") {
            return "ferry.fill"
        } else if type.contains("walk") {
            return "figure.walk"
        } else {
            return "arrow.triangle.branch"
        }
    }
}
