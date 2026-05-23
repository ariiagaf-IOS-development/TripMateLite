//
//  TripDetailsViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class TripDetailsViewController: UIViewController {
    
    private let trip: Trip
    
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
        static let routeLineHeight: CGFloat = 1
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
        
        setupHeader()
        setupScrollView()
        setupStackView()
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
        addHotelSection()
        addNoteSectionIfNeeded()
    }
    
    private func addRouteSection() {
        let sectionStack = makeSectionStack(
            iconName: trip.transportDetails.iconName,
            title: trip.transportDetails.displayType
        )
        
        let card = makeCardView()
        
        let from = trip.transportDetails.from.trimmingCharacters(in: .whitespacesAndNewlines)
        let to = trip.transportDetails.to.trimmingCharacters(in: .whitespacesAndNewlines)
        
        addRouteView(to: card, from: from, to: to)
        
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 18
        
        let firstRow = makeTwoColumnRow(
            leftTitle: "Departure",
            leftValue: trip.transportDetails.departureDate.tripDateTimeString,
            rightTitle: "Company",
            rightValue: trip.transportDetails.company
        )
        
        let secondRow = makeTwoColumnRow(
            leftTitle: "Transport",
            leftValue: trip.transportDetails.displayType,
            rightTitle: "Booking No.",
            rightValue: trip.transportDetails.bookingNumber
        )
        
        gridStack.addArrangedSubview(firstRow)
        gridStack.addArrangedSubview(secondRow)
        
        card.addArrangedSubview(gridStack)
        sectionStack.addArrangedSubview(card)
        
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addHotelSection() {
        let sectionStack = makeSectionStack(
            iconName: "building.2.fill",
            title: "Hotel"
        )
        
        let card = makeCardView()
        
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
        
        card.addArrangedSubview(makeSeparator())
        
        let datesRow = makeTwoColumnRow(
            leftTitle: "Check-in",
            leftValue: trip.hotelDetails.checkInDate.tripDateTimeString,
            rightTitle: "Check-out",
            rightValue: trip.hotelDetails.checkOutDate.tripDateTimeString,
            useMutedBackground: true
        )
        
        card.addArrangedSubview(datesRow)
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
    
    private func addRouteView(to card: UIStackView, from: String, to: String) {
        let routeStack = UIStackView()
        routeStack.axis = .horizontal
        routeStack.alignment = .center
        routeStack.spacing = 12
        
        let fromLabel = makeRoutePlaceLabel(text: from.isEmpty ? "From" : from)
        let toLabel = makeRoutePlaceLabel(text: to.isEmpty ? "To" : to)
        
        let lineContainer = UIView()
        let lineView = UIView()
        let routeImageView = UIImageView(
            image: UIImage(systemName: trip.transportDetails.iconName)
        )
        
        lineView.backgroundColor = .systemGray5
        routeImageView.tintColor = .systemBlue
        routeImageView.backgroundColor = .cardBackground
        routeImageView.contentMode = .scaleAspectFit
        
        lineContainer.addSubview(lineView)
        lineContainer.addSubview(routeImageView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        routeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineView.centerYAnchor.constraint(equalTo: lineContainer.centerYAnchor),
            lineView.leadingAnchor.constraint(equalTo: lineContainer.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: lineContainer.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Layout.routeLineHeight),
            
            routeImageView.centerXAnchor.constraint(equalTo: lineContainer.centerXAnchor),
            routeImageView.centerYAnchor.constraint(equalTo: lineContainer.centerYAnchor),
            routeImageView.widthAnchor.constraint(equalToConstant: 24),
            routeImageView.heightAnchor.constraint(equalToConstant: 24),
            
            lineContainer.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        routeStack.addArrangedSubview(fromLabel)
        routeStack.addArrangedSubview(lineContainer)
        routeStack.addArrangedSubview(toLabel)
        
        fromLabel.widthAnchor.constraint(equalTo: routeStack.widthAnchor, multiplier: 0.28).isActive = true
        toLabel.widthAnchor.constraint(equalTo: routeStack.widthAnchor, multiplier: 0.28).isActive = true
        
        card.addArrangedSubview(routeStack)
        card.addArrangedSubview(makeSeparator())
    }
    
    private func makeRoutePlaceLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
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
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
}
