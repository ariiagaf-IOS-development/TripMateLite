//
//  ActivityDetailsViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class ActivityDetailsViewController: UIViewController {
    
    var onActivityDeleted: ((TripActivity) -> Void)?
    
    var onActivityUpdated: ((TripActivity) -> Void)?
    
    private var activity: TripActivity
    
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
        static let cardInnerSpacing: CGFloat = 18
        
        static let sectionTitleFontSize: CGFloat = 15
        static let cardTitleFontSize: CGFloat = 19
        static let labelFontSize: CGFloat = 11
        static let valueFontSize: CGFloat = 15
        static let iconSize: CGFloat = 22
    }
    
    init(activity: TripActivity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupCloseButton()
        setupEditButton()
        setupHeader()
        setupScrollView()
        setupStackView()
        setupContent()
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
    }
    
    @objc private func editTapped() {
        let editViewController = AddActivityViewController(activity: activity)
        
        editViewController.onActivityUpdated = { [weak self] updatedActivity in
            guard let self else {
                return
            }
            
            self.activity = updatedActivity
            self.onActivityUpdated?(updatedActivity)
            self.reloadDetails()
        }
        
        let navigationController = UINavigationController(
            rootViewController: editViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func setupHeader() {
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = activity.title
        titleLabel.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        dateLabel.text = activityDateText()
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
    
    private func setupContent() {
        addActivityInfoSection()
        addRouteSectionIfNeeded()
        addReturnRouteSectionIfNeeded()
        addNoteSectionIfNeeded()
    }
    
    private func reloadDetails() {
        titleLabel.text = activity.title
        dateLabel.text = activityDateText()
        
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        setupContent()
    }
    
    private func addActivityInfoSection() {
        let sectionStack = makeSectionStack(
            iconName: "map.fill",
            title: "Activity Info"
        )
        
        let card = makeCardView()
        
        let activityTitleLabel = UILabel()
        activityTitleLabel.text = activity.title
        activityTitleLabel.font = .systemFont(
            ofSize: Layout.cardTitleFontSize,
            weight: .bold
        )
        activityTitleLabel.textColor = .label
        activityTitleLabel.numberOfLines = 0
        
        card.addArrangedSubview(activityTitleLabel)
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "Date",
                leftValue: activity.date.tripDateString,
                rightTitle: "Time",
                rightValue: activity.hasTime ? activity.time.tripTimeString : "Not specified",
                useMutedBackground: true
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        let location = activity.location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        card.addArrangedSubview(
            makeIconTextRow(
                iconName: "mappin.circle.fill",
                text: location.isEmpty ? "No location" : location
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeInfoBlock(
                title: "Booking No.",
                value: activity.bookingNumber,
                useMutedBackground: false
            )
        )
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addRouteSectionIfNeeded() {
        guard activity.hasRouteDetails else {
            return
        }
        
        let route = activity.routeDetails
        
        let sectionStack = makeSectionStack(
            iconName: route.iconName,
            title: "Route Details"
        )
        
        let card = makeCardView()
        
        card.addArrangedSubview(
            makeInfoBlock(
                title: "Transport Type",
                value: route.displayType,
                useMutedBackground: true
            )
        )
        
        card.addArrangedSubview(
            makeRouteLineView(
                from: route.from,
                to: route.to,
                iconName: route.iconName
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "From",
                leftValue: route.from,
                rightTitle: "To",
                rightValue: route.to
            )
        )
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "Departure",
                leftValue: route.departureDate.tripDateTimeString,
                rightTitle: "Arrival",
                rightValue: route.arrivalDate.tripDateTimeString
            )
        )
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "Company",
                leftValue: route.company,
                rightTitle: "Booking No.",
                rightValue: route.bookingNumber
            )
        )
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addReturnRouteSectionIfNeeded() {
        guard activity.hasReturnRoute else {
            return
        }
        
        let route = activity.returnRouteDetails
        
        let sectionStack = makeSectionStack(
            iconName: route.iconName,
            title: "Return Route"
        )
        
        let card = makeCardView()
        
        card.addArrangedSubview(
            makeInfoBlock(
                title: "Transport Type",
                value: route.displayType,
                useMutedBackground: true
            )
        )
        
        card.addArrangedSubview(
            makeRouteLineView(
                from: route.from,
                to: route.to,
                iconName: route.iconName
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "From",
                leftValue: route.from,
                rightTitle: "To",
                rightValue: route.to
            )
        )
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "Departure",
                leftValue: route.departureDate.tripDateTimeString,
                rightTitle: "Arrival",
                rightValue: route.arrivalDate.tripDateTimeString
            )
        )
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftTitle: "Company",
                leftValue: route.company,
                rightTitle: "Booking No.",
                rightValue: route.bookingNumber
            )
        )
        
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func addNoteSectionIfNeeded() {
        let note = activity.note.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        noteLabel.font = .systemFont(ofSize: 16)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0
        
        card.addArrangedSubview(noteLabel)
        sectionStack.addArrangedSubview(card)
        stackView.addArrangedSubview(sectionStack)
    }
    
    private func makeIconTextRow(
        iconName: String,
        text: String
    ) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .secondaryLabel
        iconImageView.contentMode = .scaleAspectFit
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 15, weight: .medium)
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textLabel)
        
        iconImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        return stackView
    }
    
    private func activityDateText() -> String {
        if activity.hasTime {
            return "\(activity.date.tripDateString) · \(activity.time.tripTimeString)"
        }
        
        return activity.date.tripDateString
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
        
        rowStack.addArrangedSubview(
            makeInfoBlock(
                title: leftTitle,
                value: leftValue,
                useMutedBackground: useMutedBackground
            )
        )
        
        rowStack.addArrangedSubview(
            makeInfoBlock(
                title: rightTitle,
                value: rightValue,
                useMutedBackground: useMutedBackground
            )
        )
        
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
