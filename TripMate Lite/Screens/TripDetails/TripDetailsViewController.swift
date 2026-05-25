//
//  TripDetailsViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class TripDetailsViewController: UIViewController {
    
    private var trip: Trip
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
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
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupEditButton()
        setupCloseButton()
        setupHeader()
        setupScrollView()
        setupStackView()
        setupDetailsContent()
    }
    
    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
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
        }
        
        let navigationController = UINavigationController(
            rootViewController: editViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
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
                equalTo: dateLabel.bottomAnchor,
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
            for item in trip.checklistItems {
                card.addArrangedSubview(makeChecklistItemRow(item))
            }
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
        let alert = UIAlertController(
            title: "New checklist item",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g. Passport"
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Add",
                style: .default
            ) { [weak self] _ in
                guard let self else {
                    return
                }
                
                let title = alert.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                guard !title.isEmpty else {
                    return
                }
                
                self.addChecklistItem(title: title)
            }
        )
        
        present(alert, animated: true)
    }
    
    @objc private func checklistItemTapped(_ sender: ChecklistTapGestureRecognizer) {
        guard let itemID = sender.itemID else {
            return
        }
        
        let updatedItems = trip.checklistItems.map { item in
            if item.id == itemID {
                return ChecklistItem(
                    id: item.id,
                    title: item.title,
                    isCompleted: !item.isCompleted
                )
            }
            
            return item
        }
        
        updateChecklistItems(updatedItems)
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
            basicInfo: trip.basicInfo,
            transportDetails: trip.transportDetails,
            routeSteps: trip.routeSteps,
            hotelDetails: trip.hotelDetails,
            hasHotelDetails: trip.hasHotelDetails,
            hasHotelDates: trip.hasHotelDates,
            checklistItems: sortedItems,
            hasReturnTicket: trip.hasReturnTicket,
            returnRouteSteps: trip.returnRouteSteps
        )
        
        TripStorage.shared.updateTrip(updatedTrip)
        trip = updatedTrip
        reloadDetails()
    }
    
    private func makeChecklistItemRow(_ item: ChecklistItem) -> UIView {
        let container = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(
            systemName: item.isCompleted ? "checkmark.circle.fill" : "circle"
        )
        iconImageView.tintColor = item.isCompleted ? .systemBlue : .secondaryLabel
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()

        let attributes: [NSAttributedString.Key: Any] = item.isCompleted
        ? [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
        ]
        : [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: Layout.valueFontSize, weight: .semibold)
        ]

        titleLabel.attributedText = NSAttributedString(
            string: item.title,
            attributes: attributes
        )

        titleLabel.numberOfLines = 0
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 10
            ),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])
        
        container.isUserInteractionEnabled = true
        let tapGesture = ChecklistTapGestureRecognizer(
            target: self,
            action: #selector(checklistItemTapped(_:))
        )
        tapGesture.itemID = item.id
        container.addGestureRecognizer(tapGesture)
        
        return container
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
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
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

private final class ChecklistTapGestureRecognizer: UITapGestureRecognizer {
    var itemID: UUID?
}
