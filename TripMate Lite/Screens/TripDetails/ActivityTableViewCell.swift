//
//  ActivityTableViewCell.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class ActivityTableViewCell: UITableViewCell {
    
    static let identifier = "ActivityTableViewCell"
    
    private let containerView = UIView()
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let routeLabel = UILabel()
    private let routePlaceLabel = UILabel()
    private let returnRouteLabel = UILabel()
    private let returnRoutePlaceLabel = UILabel()
    
    private enum Layout {
        static let verticalPadding: CGFloat = 7
        static let horizontalInset: CGFloat = 0
        static let contentPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let stackSpacing: CGFloat = 6
        
        static let titleFontSize: CGFloat = 17
        static let mainTextFontSize: CGFloat = 14
        static let secondaryTextFontSize: CGFloat = 13
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        clearBackground()
        
        titleLabel.text = nil
        dateLabel.text = nil
        locationLabel.text = nil
        routeLabel.text = nil
        routePlaceLabel.text = nil
        returnRouteLabel.text = nil
        returnRoutePlaceLabel.text = nil
        
        routeLabel.isHidden = true
        routePlaceLabel.isHidden = true
        returnRouteLabel.isHidden = true
        returnRoutePlaceLabel.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clearBackground()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        clearBackground()
        
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = .clear
            backgroundConfiguration = backgroundConfig
        }
    }
    
    func configure(with activity: TripActivity) {
        titleLabel.text = activity.title
        
        if activity.hasTime {
            dateLabel.text = "\(activity.date.tripDateString) · \(activity.time.tripTimeString)"
        } else {
            dateLabel.text = activity.date.tripDateString
        }
        
        let location = activity.location.trimmingCharacters(in: .whitespacesAndNewlines)
        locationLabel.text = location.isEmpty ? "No location" : location
        
        configureMainRoute(activity)
        configureReturnRoute(activity)
    }
    
    private func configureMainRoute(_ activity: TripActivity) {
        guard activity.hasRouteDetails else {
            routeLabel.isHidden = true
            routePlaceLabel.isHidden = true
            return
        }
        
        let route = activity.routeDetails
        let from = route.from.trimmingCharacters(in: .whitespacesAndNewlines)
        let to = route.to.trimmingCharacters(in: .whitespacesAndNewlines)
        let transport = route.displayType
        
        if from.isEmpty && to.isEmpty {
            routeLabel.text = transport
        } else {
            routeLabel.text = "\(transport) · \(from) → \(to)"
        }
        
        routeLabel.isHidden = false
        
        let departurePlace = route.departurePlace.trimmingCharacters(in: .whitespacesAndNewlines)
        let arrivalPlace = route.arrivalPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if departurePlace.isEmpty && arrivalPlace.isEmpty {
            routePlaceLabel.isHidden = true
        } else {
            let departureText = departurePlace.isEmpty ? "Not specified" : departurePlace
            let arrivalText = arrivalPlace.isEmpty ? "Not specified" : arrivalPlace
            
            routePlaceLabel.text = "Station / airport: \(departureText) → \(arrivalText)"
            routePlaceLabel.isHidden = false
        }
    }
    
    private func configureReturnRoute(_ activity: TripActivity) {
        guard activity.hasReturnRoute else {
            returnRouteLabel.isHidden = true
            returnRoutePlaceLabel.isHidden = true
            return
        }
        
        let route = activity.returnRouteDetails
        let from = route.from.trimmingCharacters(in: .whitespacesAndNewlines)
        let to = route.to.trimmingCharacters(in: .whitespacesAndNewlines)
        let transport = route.displayType
        
        if from.isEmpty && to.isEmpty {
            returnRouteLabel.text = "Return: \(transport)"
        } else {
            returnRouteLabel.text = "Return: \(transport) · \(from) → \(to)"
        }
        
        returnRouteLabel.isHidden = false
        
        let departurePlace = route.departurePlace.trimmingCharacters(in: .whitespacesAndNewlines)
        let arrivalPlace = route.arrivalPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if departurePlace.isEmpty && arrivalPlace.isEmpty {
            returnRoutePlaceLabel.isHidden = true
        } else {
            let departureText = departurePlace.isEmpty ? "Not specified" : departurePlace
            let arrivalText = arrivalPlace.isEmpty ? "Not specified" : arrivalPlace
            
            returnRoutePlaceLabel.text = "Return station / airport: \(departureText) → \(arrivalText)"
            returnRoutePlaceLabel.isHidden = false
        }
    }
    
    private func setupUI() {
        clearBackground()
        
        isOpaque = false
        contentView.isOpaque = false
        selectionStyle = .none
        
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = .clear
            backgroundConfiguration = backgroundConfig
        }
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = Layout.cornerRadius
        containerView.layer.borderWidth = 0
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.layer.masksToBounds = true
        containerView.clipsToBounds = true
        
        stackView.axis = .vertical
        stackView.spacing = Layout.stackSpacing
        
        titleLabel.font = .systemFont(
            ofSize: Layout.titleFontSize,
            weight: .bold
        )
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(
            ofSize: Layout.mainTextFontSize,
            weight: .medium
        )
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 0
        
        locationLabel.font = .systemFont(
            ofSize: Layout.mainTextFontSize,
            weight: .medium
        )
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 0
        
        routeLabel.font = .systemFont(
            ofSize: Layout.mainTextFontSize,
            weight: .semibold
        )
        routeLabel.textColor = .label
        routeLabel.numberOfLines = 0
        routeLabel.isHidden = true
        
        routePlaceLabel.font = .systemFont(
            ofSize: Layout.secondaryTextFontSize,
            weight: .medium
        )
        routePlaceLabel.textColor = .secondaryLabel
        routePlaceLabel.numberOfLines = 0
        routePlaceLabel.isHidden = true
        
        returnRouteLabel.font = .systemFont(
            ofSize: Layout.mainTextFontSize,
            weight: .semibold
        )
        returnRouteLabel.textColor = .label
        returnRouteLabel.numberOfLines = 0
        returnRouteLabel.isHidden = true
        
        returnRoutePlaceLabel.font = .systemFont(
            ofSize: Layout.secondaryTextFontSize,
            weight: .medium
        )
        returnRoutePlaceLabel.textColor = .secondaryLabel
        returnRoutePlaceLabel.numberOfLines = 0
        returnRoutePlaceLabel.isHidden = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(routeLabel)
        stackView.addArrangedSubview(routePlaceLabel)
        stackView.addArrangedSubview(returnRouteLabel)
        stackView.addArrangedSubview(returnRoutePlaceLabel)
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Layout.verticalPadding
            ),
            containerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.horizontalInset
            ),
            containerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.horizontalInset
            ),
            containerView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.verticalPadding
            ),
            
            stackView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Layout.contentPadding
            ),
            stackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.contentPadding
            ),
            stackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.contentPadding
            ),
            stackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Layout.contentPadding
            )
        ])
    }
    
    private func clearBackground() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView?.backgroundColor = .clear
    }
}
