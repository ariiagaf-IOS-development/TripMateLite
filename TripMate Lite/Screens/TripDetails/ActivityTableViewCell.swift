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
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let routeLabel = UILabel()
    
    private enum Layout {
        static let verticalPadding: CGFloat = 6
        static let contentPadding: CGFloat = 18
        static let cornerRadius: CGFloat = 18
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        if activity.hasRouteDetails {
            let from = activity.routeDetails.from.trimmingCharacters(in: .whitespacesAndNewlines)
            let to = activity.routeDetails.to.trimmingCharacters(in: .whitespacesAndNewlines)
            let transport = activity.routeDetails.displayType
            
            if from.isEmpty && to.isEmpty {
                routeLabel.text = transport
            } else {
                routeLabel.text = "\(transport) · \(from) → \(to)"
            }
            
            routeLabel.isHidden = false
        } else {
            routeLabel.isHidden = true
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if #available(iOS 14.0, *) {
            backgroundConfiguration = .clear()
        }
        
        selectionStyle = .none
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        containerView.backgroundColor = .cardBackground
        containerView.layer.cornerRadius = Layout.cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.06
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        
        locationLabel.font = .systemFont(ofSize: 14, weight: .medium)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 0
        
        routeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        routeLabel.textColor = .label
        routeLabel.numberOfLines = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if #available(iOS 14.0, *) {
            backgroundConfiguration = .clear()
        }
    }
    
    private func setupConstraints() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            dateLabel,
            locationLabel,
            routeLabel
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 6
        
        containerView.addSubview(stackView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Layout.verticalPadding
            ),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
}
