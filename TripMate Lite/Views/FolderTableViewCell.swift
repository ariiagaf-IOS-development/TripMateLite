//
//  FolderTableViewCell.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class FolderTableViewCell: UITableViewCell {
    
    static let identifier = "FolderTableViewCell"
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let cardPadding: CGFloat = 18
        static let cardCornerRadius: CGFloat = 20
        static let iconSize: CGFloat = 44
    }
    
    private let cardView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupCell()
        setupLayout()
    }
    
    func configure(
        with folder: TripFolder,
        upcomingCount: Int,
        pastCount: Int
    ) {
        nameLabel.text = folder.name
        
        let folderColor = folder.colorName.folderUIColor
        iconContainerView.backgroundColor = folderColor.withAlphaComponent(0.12)
        iconImageView.tintColor = folderColor
        
        let upcomingWord = upcomingCount == 1 ? "upcoming" : "upcoming"
        let pastWord = pastCount == 1 ? "past" : "past"
        
        if upcomingCount == 0 && pastCount == 0 {
            countLabel.text = "Empty folder"
        } else if upcomingCount > 0 && pastCount > 0 {
            countLabel.text = "\(upcomingCount) \(upcomingWord) · \(pastCount) \(pastWord)"
        } else if upcomingCount > 0 {
            countLabel.text = "\(upcomingCount) \(upcomingWord)"
        } else {
            countLabel.text = "\(pastCount) \(pastWord)"
        }
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.applyCardStyle()
        
        iconImageView.image = UIImage(systemName: "folder.fill")
        iconImageView.contentMode = .scaleAspectFit
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .label
        
        countLabel.font = .systemFont(ofSize: 14, weight: .medium)
        countLabel.textColor = .secondaryLabel
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .tertiaryLabel
        arrowImageView.contentMode = .scaleAspectFit
    }
    
    private func setupLayout() {
        contentView.addSubview(cardView)
        
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(countLabel)
        cardView.addSubview(arrowImageView)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainerView.layer.cornerRadius = Layout.iconSize / 2
        iconContainerView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconContainerView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Layout.cardPadding
            ),
            iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconContainerView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: Layout.cardPadding
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor,
                constant: 14
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: arrowImageView.leadingAnchor,
                constant: -12
            ),
            
            countLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            countLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -Layout.cardPadding
            ),
            
            arrowImageView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Layout.cardPadding
            ),
            arrowImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
