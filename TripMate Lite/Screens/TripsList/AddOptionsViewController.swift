//
//  AddOptionsViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class AddOptionsViewController: UIViewController {
    
    var onAddTripTapped: (() -> Void)?
    var onCreateFolderTapped: (() -> Void)?
    
    private let dimView = UIView()
    private let sheetView = UIView()
    private let stackView = UIStackView()
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let sheetPadding: CGFloat = 20
        static let sheetCornerRadius: CGFloat = 32
        static let optionCornerRadius: CGFloat = 22
        static let optionHeight: CGFloat = 92
        static let iconContainerSize: CGFloat = 52
        static let iconSize: CGFloat = 26
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDimView()
        setupSheetView()
        setupOptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    private func setupDimView() {
        view.addSubview(dimView)
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        dimView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(closeTapped)
        )
        dimView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSheetView() {
        view.addSubview(sheetView)
        sheetView.addSubview(stackView)
        
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        sheetView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.98)
        sheetView.layer.cornerRadius = Layout.sheetCornerRadius
        sheetView.layer.cornerCurve = .continuous
        sheetView.layer.shadowColor = UIColor.black.cgColor
        sheetView.layer.shadowOpacity = 0.14
        sheetView.layer.shadowOffset = CGSize(width: 0, height: -6)
        sheetView.layer.shadowRadius = 22
        
        stackView.axis = .vertical
        stackView.spacing = 14
        
        sheetView.transform = CGAffineTransform(translationX: 0, y: 260)
        sheetView.alpha = 0
        
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            sheetView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            sheetView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -18
            ),
            
            stackView.topAnchor.constraint(
                equalTo: sheetView.topAnchor,
                constant: Layout.sheetPadding
            ),
            stackView.leadingAnchor.constraint(
                equalTo: sheetView.leadingAnchor,
                constant: Layout.sheetPadding
            ),
            stackView.trailingAnchor.constraint(
                equalTo: sheetView.trailingAnchor,
                constant: -Layout.sheetPadding
            ),
            stackView.bottomAnchor.constraint(
                equalTo: sheetView.bottomAnchor,
                constant: -Layout.sheetPadding
            )
        ])
    }
    
    private func setupOptions() {
        let addTripOption = makeOptionView(
            iconName: "airplane.departure",
            title: "Add Trip",
            subtitle: "Plan your next adventure",
            tintColor: .systemBlue,
            action: #selector(addTripTapped)
        )
        
        let createFolderOption = makeOptionView(
            iconName: "folder.fill.badge.plus",
            title: "Create Folder",
            subtitle: "Organize trips by country or theme",
            tintColor: .systemPurple,
            action: #selector(createFolderTapped)
        )
        
        stackView.addArrangedSubview(addTripOption)
        stackView.addArrangedSubview(createFolderOption)
    }
    
    private func makeOptionView(
        iconName: String,
        title: String,
        subtitle: String,
        tintColor: UIColor,
        action: Selector
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.layer.cornerRadius = Layout.optionCornerRadius
        container.layer.cornerCurve = .continuous
        container.clipsToBounds = true
        
        let iconContainerView = UIView()
        iconContainerView.backgroundColor = tintColor.withAlphaComponent(0.12)
        iconContainerView.layer.cornerRadius = Layout.iconContainerSize / 2
        iconContainerView.clipsToBounds = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = tintColor
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        
        container.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(chevronImageView)
        container.addSubview(button)
        
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: Layout.optionHeight),
            
            iconContainerView.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 18
            ),
            iconContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            iconContainerView.heightAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor,
                constant: -12
            ),
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 22
            ),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            chevronImageView.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -18
            ),
            chevronImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),
            
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func animateIn() {
        UIView.animate(withDuration: 0.22) {
            self.dimView.alpha = 1
        }
        
        UIView.animate(
            withDuration: 0.34,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            self.sheetView.alpha = 1
            self.sheetView.transform = .identity
        }
    }
    
    private func dismissSheet(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.18) {
            self.dimView.alpha = 0
        }
        
        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.sheetView.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 260)
        } completion: { _ in
            self.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    @objc private func closeTapped() {
        dismissSheet()
    }
    
    @objc private func addTripTapped() {
        dismissSheet { [weak self] in
            self?.onAddTripTapped?()
        }
    }
    
    @objc private func createFolderTapped() {
        dismissSheet { [weak self] in
            self?.onCreateFolderTapped?()
        }
    }
}
