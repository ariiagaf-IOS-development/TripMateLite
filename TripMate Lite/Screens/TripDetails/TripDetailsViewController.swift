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
        static let titleFontSize: CGFloat = 32
        static let dateFontSize: CGFloat = 16
        static let titleToDateSpacing: CGFloat = 6
        static let headerToContentSpacing: CGFloat = 32
        static let bottomPadding: CGFloat = 24
        
        static let stackSpacing: CGFloat = 16
        
        static let cardPadding: CGFloat = 20
        static let cardCornerRadius: CGFloat = 16
        static let cardSpacing: CGFloat = 16
        static let cardInnerSpacing: CGFloat = 14
        
        static let cardTitleFontSize: CGFloat = 22
        static let labelFontSize: CGFloat = 14
        static let valueFontSize: CGFloat = 16
        static let detailTitleToValueSpacing: CGFloat = 4
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
        title = "TripMate"
        
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
        dateLabel.font = .systemFont(ofSize: Layout.dateFontSize)
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
        addTransportCard()
        addHotelCard()
        addNoteCardIfNeeded()
    }
    
    private func makeCardView() -> UIStackView {
        let cardStackView = UIStackView()
        
        cardStackView.axis = .vertical
        cardStackView.spacing = Layout.cardInnerSpacing
        cardStackView.applyCardStyle()
        
        cardStackView.layoutMargins = UIEdgeInsets(
            top: Layout.cardPadding,
            left: Layout.cardPadding,
            bottom: Layout.cardPadding,
            right: Layout.cardPadding
        )
        cardStackView.isLayoutMarginsRelativeArrangement = true
        
        return cardStackView
    }
    
    private func addCardTitle(to card: UIStackView, title: String) {
        let titleLabel = UILabel()
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.cardTitleFontSize, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        card.addArrangedSubview(titleLabel)
    }
    
    private func addCardText(to card: UIStackView, text: String) {
        let textLabel = UILabel()
        
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: Layout.valueFontSize)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        
        card.addArrangedSubview(textLabel)
    }
    
    private func addCardRow(to card: UIStackView, title: String, value: String) {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedValue.isEmpty else {
            return
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.labelFontSize)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = trimmedValue
        valueLabel.font = .systemFont(ofSize: Layout.valueFontSize)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        
        let rowStackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        rowStackView.axis = .vertical
        rowStackView.spacing = Layout.detailTitleToValueSpacing
        
        card.addArrangedSubview(rowStackView)
    }
    
    private func addTransportCard() {
        let card = makeCardView()
        
        let transportType = trip.transportDetails.transportType
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        addCardTitle(
            to: card,
            title: transportType.isEmpty ? "Transport" : transportType
        )
        
        let from = trip.transportDetails.from
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let to = trip.transportDetails.to
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !from.isEmpty || !to.isEmpty {
            addCardText(to: card, text: "\(from) → \(to)")
        }
        
        addCardRow(
            to: card,
            title: "Departure",
            value: trip.transportDetails.departureDate.tripDateTimeString
        )
        
        addCardRow(
            to: card,
            title: "Arrival",
            value: trip.transportDetails.arrivalDate.tripDateTimeString
        )
        
        addCardRow(
            to: card,
            title: "Company",
            value: trip.transportDetails.company
        )
        
        addCardRow(
            to: card,
            title: "Booking / Route Number",
            value: trip.transportDetails.bookingNumber
        )
        
        stackView.addArrangedSubview(card)
        stackView.setCustomSpacing(Layout.cardSpacing, after: card)
    }
    
    private func addHotelCard() {
        let card = makeCardView()
        
        addCardTitle(to: card, title: "Hotel")
        
        let hotelName = trip.hotelDetails.hotelName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !hotelName.isEmpty {
            addCardText(to: card, text: hotelName)
        }
        
        addCardRow(
            to: card,
            title: "Address",
            value: trip.hotelDetails.address
        )
        
        addCardRow(
            to: card,
            title: "Check-in",
            value: trip.hotelDetails.checkInDate.tripDateTimeString
        )
        
        addCardRow(
            to: card,
            title: "Check-out",
            value: trip.hotelDetails.checkOutDate.tripDateTimeString
        )
        
        stackView.addArrangedSubview(card)
        stackView.setCustomSpacing(Layout.cardSpacing, after: card)
    }
    
    private func addNoteCardIfNeeded() {
        let note = trip.basicInfo.note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !note.isEmpty else {
            return
        }
        
        let card = makeCardView()
        
        addCardTitle(to: card, title: "Note")
        addCardText(to: card, text: note)
        
        stackView.addArrangedSubview(card)
    }
}
