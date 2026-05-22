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
        static let dateToInfoSpacing: CGFloat = 20
        static let infoRowSpacing: CGFloat = 14
        static let iconToTextSpacing: CGFloat = 12
        static let titleToValueSpacing: CGFloat = 3
        
        static let cornerRadius: CGFloat = 20
        static let iconContainerSize: CGFloat = 32
        static let iconSize: CGFloat = 18
        
        static let destinationFontSize: CGFloat = 22
        static let dateFontSize: CGFloat = 14
        static let sectionTitleFontSize: CGFloat = 11
        static let valueFontSize: CGFloat = 14
    }
    
    private let containerView = UIView()
    
    private let destinationLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let flightIconContainerView = UIView()
    private let flightIconImageView = UIImageView()
    private let flightTitleLabel = UILabel()
    private let routeLabel = UILabel()
    
    private let hotelIconContainerView = UIView()
    private let hotelIconImageView = UIImageView()
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
    
    func configure(with trip: Trip) {
        destinationLabel.text = trip.basicInfo.destination
        
        let startDate = trip.basicInfo.startDate.tripDateString
        let endDate = trip.basicInfo.endDate.tripDateString
        dateLabel.text = "\(startDate) — \(endDate)"
        
        let from = trip.transportDetails.from.trimmingCharacters(in: .whitespacesAndNewlines)
        let to = trip.transportDetails.to.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if from.isEmpty && to.isEmpty {
            routeLabel.text = "No flight details"
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
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        containerView.applyCardStyle()
        
        destinationLabel.font = .systemFont(
            ofSize: Layout.destinationFontSize,
            weight: .semibold
        )
        destinationLabel.textColor = .label
        
        dateLabel.font = .systemFont(
            ofSize: Layout.dateFontSize,
            weight: .medium
        )
        dateLabel.textColor = .secondaryLabel
        
        setupIconContainer(
            flightIconContainerView,
            imageView: flightIconImageView,
            systemName: "airplane"
        )
        
        setupIconContainer(
            hotelIconContainerView,
            imageView: hotelIconImageView,
            systemName: "building.2.fill"
        )
        
        setupInfoTitleLabel(flightTitleLabel, text: "Flight")
        setupInfoTitleLabel(hotelTitleLabel, text: "Hotel")
        
        setupInfoValueLabel(routeLabel)
        setupInfoValueLabel(hotelNameLabel)
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(destinationLabel)
        containerView.addSubview(dateLabel)
        
        let flightRow = makeInfoRow(
            iconContainerView: flightIconContainerView,
            titleLabel: flightTitleLabel,
            valueLabel: routeLabel
        )
        
        let hotelRow = makeInfoRow(
            iconContainerView: hotelIconContainerView,
            titleLabel: hotelTitleLabel,
            valueLabel: hotelNameLabel
        )
        
        let infoStackView = UIStackView(arrangedSubviews: [flightRow, hotelRow])
        infoStackView.axis = .vertical
        infoStackView.spacing = Layout.infoRowSpacing
        
        containerView.addSubview(infoStackView)
        
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            infoStackView.topAnchor.constraint(
                equalTo: dateLabel.bottomAnchor,
                constant: Layout.dateToInfoSpacing
            ),
            infoStackView.leadingAnchor.constraint(equalTo: destinationLabel.leadingAnchor),
            infoStackView.trailingAnchor.constraint(equalTo: destinationLabel.trailingAnchor),
            infoStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Layout.contentPadding
            )
        ])
    }
    
    private func setupIconContainer(
        _ containerView: UIView,
        imageView: UIImageView,
        systemName: String
    ) {
        containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        containerView.layer.cornerRadius = Layout.iconContainerSize / 2
        containerView.clipsToBounds = true
        
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(imageView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            containerView.heightAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            imageView.heightAnchor.constraint(equalToConstant: Layout.iconSize)
        ])
    }
    
    private func setupInfoTitleLabel(_ label: UILabel, text: String) {
        label.text = text.uppercased()
        label.font = .systemFont(
            ofSize: Layout.sectionTitleFontSize,
            weight: .bold
        )
        label.textColor = .secondaryLabel
    }
    
    private func setupInfoValueLabel(_ label: UILabel) {
        label.font = .systemFont(
            ofSize: Layout.valueFontSize,
            weight: .medium
        )
        label.textColor = .label
        label.numberOfLines = 0
    }
    
    private func makeInfoRow(
        iconContainerView: UIView,
        titleLabel: UILabel,
        valueLabel: UILabel
    ) -> UIStackView {
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStackView.axis = .vertical
        textStackView.spacing = Layout.titleToValueSpacing
        
        let rowStackView = UIStackView(arrangedSubviews: [iconContainerView, textStackView])
        rowStackView.axis = .horizontal
        rowStackView.spacing = Layout.iconToTextSpacing
        rowStackView.alignment = .center
        
        return rowStackView
    }
}
