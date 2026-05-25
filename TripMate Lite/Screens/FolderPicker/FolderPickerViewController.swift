//
//  FolderPickerViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class FolderPickerViewController: UIViewController {
    
    var onFolderSelected: ((UUID?) -> Void)?
    
    private let folders: [TripFolder]
    private let selectedFolderID: UUID?
    
    private let dimView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let handleView = UIView()
    private let closeButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let containerCornerRadius: CGFloat = 28
        static let rowHeight: CGFloat = 58
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 22
    }
    
    init(
        folders: [TripFolder],
        selectedFolderID: UUID?
    ) {
        self.folders = folders
        self.selectedFolderID = selectedFolderID
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDimView()
        setupContainer()
        setupTitle()
        setupTableView()
        setupCloseButton()
    }
    
    private func setupDimView() {
        view.addSubview(dimView)
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(cancelTapped)
        )
        dimView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContainer() {
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = Layout.containerCornerRadius
        containerView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        containerView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTitle() {
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        handleView.backgroundColor = .systemGray4
        handleView.layer.cornerRadius = 2
        
        titleLabel.text = "Move trip"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: 10
            ),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 44),
            handleView.heightAnchor.constraint(equalToConstant: 4),
            
            titleLabel.topAnchor.constraint(
                equalTo: handleView.bottomAnchor,
                constant: 18
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -64
            )
        ])
    }
    
    private func setupCloseButton() {
        containerView.addSubview(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.setImage(
            UIImage(systemName: "xmark.circle.fill"),
            for: .normal
        )
        closeButton.tintColor = .systemGray3
        closeButton.addTarget(
            self,
            action: #selector(cancelTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTableView() {
        containerView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Layout.rowHeight
        tableView.isScrollEnabled = folders.count > 5
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            FolderPickerCell.self,
            forCellReuseIdentifier: FolderPickerCell.identifier
        )
        
        let visibleRows = min(folders.count + 1, 6)
        let tableHeight = CGFloat(visibleRows) * Layout.rowHeight
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 16
            ),
            tableView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            tableView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.bottomPadding
            )
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension FolderPickerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        folders.count + 1
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FolderPickerCell.identifier,
            for: indexPath
        ) as? FolderPickerCell
        
        if indexPath.row == 0 {
            cell?.configure(
                title: "No Folder",
                color: .secondaryLabel,
                isSelected: selectedFolderID == nil,
                iconName: "tray.fill"
            )
        } else {
            let folder = folders[indexPath.row - 1]
            
            cell?.configure(
                title: folder.name,
                color: folder.colorName.folderUIColor,
                isSelected: folder.id == selectedFolderID,
                iconName: "folder.fill"
            )
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedID: UUID?
        
        if indexPath.row == 0 {
            selectedID = nil
        } else {
            selectedID = folders[indexPath.row - 1].id
        }
        
        onFolderSelected?(selectedID)
        dismiss(animated: true)
    }
}

final class FolderPickerCell: UITableViewCell {
    
    static let identifier = "FolderPickerCell"
    
    private let cardView = UIView()
    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(checkmarkImageView)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        iconBackgroundView.layer.cornerRadius = 17
        iconBackgroundView.clipsToBounds = true
        
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemBlue
        checkmarkImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            iconBackgroundView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 14
            ),
            iconBackgroundView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 34),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 34),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: iconBackgroundView.trailingAnchor,
                constant: 12
            ),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            checkmarkImageView.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor,
                constant: 12
            ),
            checkmarkImageView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -14
            ),
            checkmarkImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 22),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    func configure(
        title: String,
        color: UIColor,
        isSelected: Bool,
        iconName: String
    ) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = color
        iconBackgroundView.backgroundColor = color.withAlphaComponent(0.14)
        checkmarkImageView.isHidden = !isSelected
    }
}
