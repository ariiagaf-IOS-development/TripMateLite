//
//  TripTableViewCell.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 15.05.2026.
//

import UIKit

final class TripTableViewCell: UITableViewCell {
    
    static let identifier = "TripTableViewCell"
    
    private enum Layout {
        static let cardVerticalPadding: CGFloat = 8
        static let cardHorizontalPadding: CGFloat = 20
        
        static let contentPadding: CGFloat = 20
        
        static let destinationToDateSpacing: CGFloat = 6
        static let dateToTransportSpacing: CGFloat = 18
        static let titleToValueSpacing: CGFloat = 6
        static let transportToHotelSpacing: CGFloat = 14
        
        static let cornerRadius: CGFloat = 16
        
        static let destinationFontSize: CGFloat = 22
        static let dateFontSize: CGFloat = 15
        static let sectionTitleFontSize: CGFloat = 14
        static let valueFontSize: CGFloat = 16
    }
    
    private let containerView = UIView()
    
    private let destinationLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let transportTitleLabel = UILabel()
    private let routeLabel = UILabel()
    
    private let hotelTitleLabel = UILabel()
    private let hotelNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        containerView.applyCardStyle()
        
        destinationLabel.font = .systemFont(
            ofSize: Layout.destinationFontSize,
            weight: .bold
        )
        destinationLabel.textColor = .label
        
        dateLabel.font = .systemFont(ofSize: Layout.dateFontSize)
        dateLabel.textColor = .secondaryLabel
        
        transportTitleLabel.text = "Transport"
        transportTitleLabel.font = .systemFont(
            ofSize: Layout.sectionTitleFontSize,
            weight: .semibold
        )
        transportTitleLabel.textColor = .secondaryLabel
        
        routeLabel.font = .systemFont(ofSize: Layout.valueFontSize)
        routeLabel.textColor = .label
        
        hotelTitleLabel.text = "Hotel"
        hotelTitleLabel.font = .systemFont(
            ofSize: Layout.sectionTitleFontSize,
            weight: .semibold
        )
        hotelTitleLabel.textColor = .secondaryLabel
        
        hotelNameLabel.font = .systemFont(ofSize: Layout.valueFontSize)
        hotelNameLabel.textColor = .label
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        transportTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        routeLabel.translatesAutoresizingMaskIntoConstraints = false
        hotelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hotelNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(destinationLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(transportTitleLabel)
        containerView.addSubview(routeLabel)
        containerView.addSubview(hotelTitleLabel)
        containerView.addSubview(hotelNameLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Layout.cardVerticalPadding
            ),
            containerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.cardHorizontalPadding
            ),
            containerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.cardHorizontalPadding
            ),
            containerView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.cardVerticalPadding
            ),
            
            destinationLabel.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Layout.contentPadding
            ),
            destinationLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.contentPadding
            ),
            destinationLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.contentPadding
            ),
            
            dateLabel.topAnchor.constraint(
                equalTo: destinationLabel.bottomAnchor,
                constant: Layout.destinationToDateSpacing
            ),
            dateLabel.leadingAnchor.constraint(equalTo: destinationLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: destinationLabel.trailingAnchor),
            
            transportTitleLabel.topAnchor.constraint(
                equalTo: dateLabel.bottomAnchor,
                constant: Layout.dateToTransportSpacing
            ),
            transportTitleLabel.leadingAnchor.constraint(equalTo: destinationLabel.leadingAnchor),
            transportTitleLabel.trailingAnchor.constraint(equalTo: destinationLabel.trailingAnchor),
            
            routeLabel.topAnchor.constraint(
                equalTo: transportTitleLabel.bottomAnchor,
                constant: Layout.titleToValueSpacing
            ),
            routeLabel.leadingAnchor.constraint(equalTo: destinationLabel.leadingAnchor),
            routeLabel.trailingAnchor.constraint(equalTo: destinationLabel.trailingAnchor),
            
            hotelTitleLabel.topAnchor.constraint(
                equalTo: routeLabel.bottomAnchor,
                constant: Layout.transportToHotelSpacing
            ),
            hotelTitleLabel.leadingAnchor.constraint(equalTo: destinationLabel.leadingAnchor),
            hotelTitleLabel.trailingAnchor.constraint(equalTo: destinationLabel.trailingAnchor),
            
            hotelNameLabel.topAnchor.constraint(
                equalTo: hotelTitleLabel.bottomAnchor,
                constant: Layout.titleToValueSpacing
            ),
            hotelNameLabel.leadingAnchor.constraint(equalTo: destinationLabel.leadingAnchor),
            hotelNameLabel.trailingAnchor.constraint(equalTo: destinationLabel.trailingAnchor),
            hotelNameLabel.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Layout.contentPadding
            )
        ])
    }
    
    func configure(with trip: Trip) {
        destinationLabel.text = trip.basicInfo.destination
        
        let startDate = trip.basicInfo.startDate.tripDateString
        let endDate = trip.basicInfo.endDate.tripDateString
        dateLabel.text = "\(startDate) — \(endDate)"
        
        let from = trip.transportDetails.from.trimmingCharacters(in: .whitespacesAndNewlines)
        let to = trip.transportDetails.to.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if from.isEmpty && to.isEmpty {
            routeLabel.text = "No transport details"
        } else {
            routeLabel.text = "\(from) → \(to)"
        }
        
        let hotelName = trip.hotelDetails.hotelName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hotelName.isEmpty {
            hotelNameLabel.text = "No hotel details"
        } else {
            hotelNameLabel.text = hotelName
        }
    }
}
