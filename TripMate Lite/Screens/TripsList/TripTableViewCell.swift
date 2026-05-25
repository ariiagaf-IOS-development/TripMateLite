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
    
    private let folderBadgeView = UIView()
    private let folderBadgeIconImageView = UIImageView()
    private let folderBadgeLabel = UILabel()
    
    private let routeIconContainerView = UIView()
    private let routeIconImageView = UIImageView()
    private let routeTitleLabel = UILabel()
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
    
    func configure(with trip: Trip, folder: TripFolder? = nil) {
        destinationLabel.text = trip.basicInfo.destination
        
        let startDate = trip.basicInfo.startDate.tripDateString
        let endDate = trip.basicInfo.endDate.tripDateString
        dateLabel.text = "\(startDate) — \(endDate)"
        
        let routeSteps = trip.routeSteps

        if routeSteps.count > 1 {
            routeIconImageView.image = UIImage(systemName: "arrow.triangle.branch")
            routeTitleLabel.text = "ROUTE"
            
            let firstFrom = routeSteps.first?.from.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let finalTo = routeSteps.last?.to.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if firstFrom.isEmpty && finalTo.isEmpty {
                routeLabel.text = "\(routeSteps.count) steps"
            } else {
                routeLabel.text = "\(firstFrom) → \(finalTo) · \(routeSteps.count) steps"
            }
        } else {
            routeIconImageView.image = UIImage(systemName: trip.transportDetails.iconName)
            routeTitleLabel.text = trip.transportDetails.displayType.uppercased()
            
            let from = trip.transportDetails.from.trimmingCharacters(in: .whitespacesAndNewlines)
            let to = trip.transportDetails.to.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if from.isEmpty && to.isEmpty {
                routeLabel.text = "No route details"
            } else if from.isEmpty {
                routeLabel.text = to
            } else if to.isEmpty {
                routeLabel.text = from
            } else {
                routeLabel.text = "\(from) → \(to)"
            }
        }
        
        let hotelName = trip.hotelDetails.hotelName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hotelName.isEmpty {
            hotelNameLabel.text = "No hotel details"
        } else {
            hotelNameLabel.text = hotelName
        }
        
        if let folder {
            folderBadgeView.isHidden = false
            folderBadgeLabel.text = folder.name
            folderBadgeView.backgroundColor = folder.colorName.folderUIColor.withAlphaComponent(0.10)
            folderBadgeIconImageView.tintColor = folder.colorName.folderUIColor
            folderBadgeLabel.textColor = folder.colorName.folderUIColor
        } else {
            folderBadgeView.isHidden = true
            folderBadgeLabel.text = nil
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
        
        folderBadgeView.layer.cornerRadius = 13
        folderBadgeView.clipsToBounds = true
        folderBadgeView.isHidden = true

        folderBadgeIconImageView.image = UIImage(systemName: "folder.fill")
        folderBadgeIconImageView.contentMode = .scaleAspectFit

        folderBadgeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        folderBadgeLabel.numberOfLines = 1
        
        setupIconContainer(
            routeIconContainerView,
            imageView: routeIconImageView,
            systemName: "arrow.triangle.branch"
        )
        
        setupIconContainer(
            hotelIconContainerView,
            imageView: hotelIconImageView,
            systemName: "building.2.fill"
        )
        
        setupInfoTitleLabel(routeTitleLabel, text: "Route")
        setupInfoTitleLabel(hotelTitleLabel, text: "Hotel")
        
        setupInfoValueLabel(routeLabel)
        setupInfoValueLabel(hotelNameLabel)
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        let routeRow = makeInfoRow(
            iconContainerView: routeIconContainerView,
            titleLabel: routeTitleLabel,
            valueLabel: routeLabel
        )
        
        let hotelRow = makeInfoRow(
            iconContainerView: hotelIconContainerView,
            titleLabel: hotelTitleLabel,
            valueLabel: hotelNameLabel
        )
        
        let infoStackView = UIStackView(arrangedSubviews: [routeRow, hotelRow])
        infoStackView.axis = .vertical
        infoStackView.spacing = Layout.infoRowSpacing
        
        folderBadgeView.addSubview(folderBadgeIconImageView)
        folderBadgeView.addSubview(folderBadgeLabel)
        
        let mainStackView = UIStackView(arrangedSubviews: [
            destinationLabel,
            dateLabel,
            folderBadgeView,
            infoStackView
        ])
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        
        mainStackView.setCustomSpacing(
            Layout.destinationToDateSpacing,
            after: destinationLabel
        )
        
        mainStackView.setCustomSpacing(
            10,
            after: dateLabel
        )
        
        mainStackView.setCustomSpacing(
            Layout.dateToInfoSpacing,
            after: folderBadgeView
        )
        
        containerView.addSubview(mainStackView)
        
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        folderBadgeView.translatesAutoresizingMaskIntoConstraints = false
        folderBadgeIconImageView.translatesAutoresizingMaskIntoConstraints = false
        folderBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            mainStackView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Layout.contentPadding
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.contentPadding
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.contentPadding
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Layout.contentPadding
            ),
            
            folderBadgeView.heightAnchor.constraint(equalToConstant: 26),
            folderBadgeView.widthAnchor.constraint(
                lessThanOrEqualTo: mainStackView.widthAnchor
            ),
            
            folderBadgeIconImageView.leadingAnchor.constraint(
                equalTo: folderBadgeView.leadingAnchor,
                constant: 10
            ),
            folderBadgeIconImageView.centerYAnchor.constraint(
                equalTo: folderBadgeView.centerYAnchor
            ),
            folderBadgeIconImageView.widthAnchor.constraint(equalToConstant: 14),
            folderBadgeIconImageView.heightAnchor.constraint(equalToConstant: 14),
            
            folderBadgeLabel.leadingAnchor.constraint(
                equalTo: folderBadgeIconImageView.trailingAnchor,
                constant: 6
            ),
            folderBadgeLabel.trailingAnchor.constraint(
                equalTo: folderBadgeView.trailingAnchor,
                constant: -10
            ),
            folderBadgeLabel.centerYAnchor.constraint(
                equalTo: folderBadgeView.centerYAnchor
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
