//
//  InfoViewController.swift
//  TripMate Lite
//

import UIKit

final class InfoViewController: UIViewController {
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 24
        static let titleFontSize: CGFloat = 32
        
        static let iconContainerSize: CGFloat = 96
        static let iconCornerRadius: CGFloat = 22
        static let iconImageSize: CGFloat = 56
        
        static let stackTopSpacing: CGFloat = 28
        static let stackSpacing: CGFloat = 28
        static let cardPadding: CGFloat = 20
        static let cardInnerSpacing: CGFloat = 16
        
        static let appTitleFontSize: CGFloat = 24
        static let versionFontSize: CGFloat = 15
        
        static let cardTitleFontSize: CGFloat = 17
        static let bodyFontSize: CGFloat = 15
        static let rowFontSize: CGFloat = 15
        static let actionFontSize: CGFloat = 17
        static let footerFontSize: CGFloat = 13
        
        static let rowIconSize: CGFloat = 32
        static let rowIconCornerRadius: CGFloat = 8
        static let actionVerticalPadding: CGFloat = 10
    }
    
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupTitleLabel()
        setupScrollView()
        setupStackView()
        setupContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        let bottomInset = tabBarHeight + view.safeAreaInsets.bottom
        
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Info"
        titleLabel.font = .systemFont(
            ofSize: Layout.titleFontSize,
            weight: .bold
        )
        titleLabel.textColor = .label
        
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
            )
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
                equalTo: titleLabel.bottomAnchor,
                constant: Layout.stackTopSpacing
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
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupContent() {
        stackView.addArrangedSubview(makeAppHeaderView())
        stackView.addArrangedSubview(makeAboutCard())
        stackView.addArrangedSubview(makeActionsView())
        stackView.addArrangedSubview(makeFooterLabel())
    }
    
    private func makeAppHeaderView() -> UIView {
        let container = UIView()
        
        let iconContainer = UIView()
        iconContainer.applyCardStyle()
        iconContainer.layer.cornerRadius = Layout.iconCornerRadius
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "AppIconPreview") ?? UIImage(systemName: "airplane.departure")
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        let appNameLabel = UILabel()
        appNameLabel.text = "TripMate Lite"
        appNameLabel.font = .systemFont(
            ofSize: Layout.appTitleFontSize,
            weight: .bold
        )
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        
        let versionLabel = UILabel()
        versionLabel.text = "Version 1.0.0"
        versionLabel.font = .systemFont(
            ofSize: Layout.versionFontSize,
            weight: .medium
        )
        versionLabel.textColor = .secondaryLabel
        versionLabel.textAlignment = .center
        
        container.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        container.addSubview(appNameLabel)
        container.addSubview(versionLabel)
        
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: container.topAnchor),
            iconContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            iconContainer.heightAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconImageSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconImageSize),
            
            appNameLabel.topAnchor.constraint(
                equalTo: iconContainer.bottomAnchor,
                constant: 16
            ),
            appNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            appNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            versionLabel.topAnchor.constraint(
                equalTo: appNameLabel.bottomAnchor,
                constant: 4
            ),
            versionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func makeAboutCard() -> UIView {
        let card = UIView()
        card.applyCardStyle()
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.cardInnerSpacing
        
        let aboutTitleLabel = UILabel()
        aboutTitleLabel.text = "About the App"
        aboutTitleLabel.font = .systemFont(
            ofSize: Layout.cardTitleFontSize,
            weight: .bold
        )
        aboutTitleLabel.textColor = .label
        
        let aboutTextLabel = UILabel()
        aboutTextLabel.text = "TripMate Lite is your minimalistic travel companion. Designed to be fast, private, and offline-first, it keeps your itineraries safe on your device without the need for an account."
        aboutTextLabel.font = .systemFont(ofSize: Layout.bodyFontSize)
        aboutTextLabel.textColor = .secondaryLabel
        aboutTextLabel.numberOfLines = 0
        
        stack.addArrangedSubview(aboutTitleLabel)
        stack.addArrangedSubview(aboutTextLabel)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(
            makeStatusRow(
                iconName: "shield.checkerboard",
                title: "Privacy First"
            )
        )
        stack.addArrangedSubview(
            makeStatusRow(
                iconName: "icloud.slash.fill",
                title: "Offline Storage"
            )
        )
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: Layout.cardPadding
            ),
            stack.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: Layout.cardPadding
            ),
            stack.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -Layout.cardPadding
            ),
            stack.bottomAnchor.constraint(
                equalTo: card.bottomAnchor,
                constant: -Layout.cardPadding
            )
        ])
        
        return card
    }
    
    private func makeStatusRow(iconName: String, title: String) -> UIView {
        let row = UIView()
        
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        leftStack.spacing = 12
        leftStack.alignment = .center
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        iconContainer.layer.cornerRadius = Layout.rowIconCornerRadius
        iconContainer.clipsToBounds = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(
            ofSize: Layout.rowFontSize,
            weight: .medium
        )
        titleLabel.textColor = .label
        
        let checkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkImageView.tintColor = .systemBlue
        checkImageView.contentMode = .scaleAspectFit
        
        row.addSubview(leftStack)
        row.addSubview(checkImageView)
        iconContainer.addSubview(iconImageView)
        
        leftStack.addArrangedSubview(iconContainer)
        leftStack.addArrangedSubview(titleLabel)
        
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftStack.topAnchor.constraint(equalTo: row.topAnchor),
            leftStack.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            leftStack.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            
            iconContainer.widthAnchor.constraint(equalToConstant: Layout.rowIconSize),
            iconContainer.heightAnchor.constraint(equalToConstant: Layout.rowIconSize),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            checkImageView.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 22),
            checkImageView.heightAnchor.constraint(equalToConstant: 22),
            
            leftStack.trailingAnchor.constraint(
                lessThanOrEqualTo: checkImageView.leadingAnchor,
                constant: -12
            )
        ])
        
        return row
    }
    
    private func makeActionsView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        
        stack.addArrangedSubview(
            makeActionRow(
                iconName: "envelope.fill",
                title: "Send Feedback"
            )
        )
        
        stack.addArrangedSubview(
            makeActionRow(
                iconName: "star.fill",
                title: "Rate on App Store"
            )
        )
        
        return stack
    }
    
    private func makeActionRow(iconName: String, title: String) -> UIView {
        let row = UIView()
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .secondaryLabel
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(
            ofSize: Layout.actionFontSize,
            weight: .medium
        )
        titleLabel.textColor = .label
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        
        row.addSubview(iconImageView)
        row.addSubview(titleLabel)
        row.addSubview(chevronImageView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconImageView.topAnchor.constraint(
                equalTo: row.topAnchor,
                constant: Layout.actionVerticalPadding
            ),
            iconImageView.bottomAnchor.constraint(
                equalTo: row.bottomAnchor,
                constant: -Layout.actionVerticalPadding
            ),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 12
            ),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            chevronImageView.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),
            
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: chevronImageView.leadingAnchor,
                constant: -12
            )
        ])
        
        return row
    }
    
    private func makeFooterLabel() -> UILabel {
        let label = UILabel()
        label.text = "Designed with ♡ for travelers\nby Ari <3"
        label.font = .systemFont(ofSize: Layout.footerFontSize)
        label.textColor = UIColor.secondaryLabel.withAlphaComponent(0.65)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.7)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
}
