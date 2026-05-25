//
//  CreateFolderViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class CreateFolderViewController: UIViewController {
    
    var onFolderDeleted: ((TripFolder) -> Void)?
    
    private var initialFormSnapshot = ""
    
    private let editingFolder: TripFolder?
    var onFolderUpdated: ((TripFolder) -> Void)?
    var onFolderCreated: ((TripFolder) -> Void)?
    
    private let nameTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let colorsStackView = UIStackView()
    
    private let availableColors = [
        "blue",
        "purple",
        "orange",
        "green",
        "pink",
        "gray"
    ]
    
    private var selectedColorName = "blue"
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 28
        static let titleFontSize: CGFloat = 32
        static let cardCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 56
        static let colorButtonSize: CGFloat = 44
    }
    
    init(folder: TripFolder? = nil) {
        self.editingFolder = folder
        
        if let folder {
            self.selectedColorName = folder.colorName
        }
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.editingFolder = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupCloseButton()
        setupDeleteButtonIfNeeded()
        setupContent()
        setupKeyboardDismissGesture()
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    private func setupDeleteButtonIfNeeded() {
        guard editingFolder != nil else {
            return
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteFolderTapped)
        )
        
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }
    
    @objc private func deleteFolderTapped() {
        let alert = UIAlertController(
            title: "Delete folder?",
            message: "Trips inside this folder will not be deleted. They will move back to the main list.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                guard let self,
                      let editingFolder = self.editingFolder else {
                    return
                }
                
                self.onFolderDeleted?(editingFolder)
                self.dismiss(animated: true)
            }
        )
        
        present(alert, animated: true)
    }
    
    @objc private func cancelTapped() {
        if hasUnsavedChanges() {
            showDiscardChangesAlert()
        } else {
            dismiss(animated: true)
        }
    }
    
    private func hasUnsavedChanges() -> Bool {
        makeFormSnapshot() != initialFormSnapshot
    }

    private func makeFormSnapshot() -> String {
        [
            nameTextField.text ?? "",
            selectedColorName
        ].joined(separator: "###")
    }

    private func showDiscardChangesAlert() {
        let alert = UIAlertController(
            title: "Discard changes?",
            message: "Your folder changes will not be saved.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Discard",
                style: .destructive
            ) { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        
        present(alert, animated: true)
    }
    
    private func setupContent() {
        let titleLabel = UILabel()
        titleLabel.text = editingFolder == nil ? "New Folder" : "Edit Folder"
        titleLabel.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        
        let cardView = UIView()
        cardView.applyCardStyle()
        
        let nameLabel = UILabel()
        nameLabel.text = "FOLDER NAME"
        nameLabel.font = .systemFont(ofSize: 12, weight: .bold)
        nameLabel.textColor = .secondaryLabel
        
        nameTextField.placeholder = "Eurotrip 2026"
        nameTextField.borderStyle = .none
        nameTextField.font = .systemFont(ofSize: 17, weight: .medium)
        nameTextField.autocapitalizationType = .words
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        nameTextField.addTarget(
            self,
            action: #selector(nameChanged),
            for: .editingChanged
        )
        
        if let editingFolder {
            nameTextField.text = editingFolder.name
        }
        
        let colorLabel = UILabel()
        colorLabel.text = "COLOR"
        colorLabel.font = .systemFont(ofSize: 12, weight: .bold)
        colorLabel.textColor = .secondaryLabel
        
        colorsStackView.axis = .horizontal
        colorsStackView.spacing = 12
        colorsStackView.distribution = .fillEqually
        
        for colorName in availableColors {
            let button = makeColorButton(colorName: colorName)
            colorsStackView.addArrangedSubview(button)
        }
        
        let buttonTitle = editingFolder == nil ? "Create Folder" : "Save Changes"
        saveButton.setTitle(buttonTitle, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        saveButton.tintColor = .white
        saveButton.backgroundColor = .systemGray4
        saveButton.layer.cornerRadius = 20
        saveButton.isEnabled = false
        saveButton.addTarget(
            self,
            action: #selector(saveTapped),
            for: .touchUpInside
        )
        
        view.addSubview(titleLabel)
        view.addSubview(cardView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(nameTextField)
        cardView.addSubview(colorLabel)
        cardView.addSubview(colorsStackView)
        view.addSubview(saveButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorsStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            cardView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            colorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            colorLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            colorsStackView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
            colorsStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            colorsStackView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            colorsStackView.heightAnchor.constraint(equalToConstant: Layout.colorButtonSize),
            colorsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),

            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            saveButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
        
        nameChanged()
        
        initialFormSnapshot = makeFormSnapshot()
    }
    
    private func makeColorButton(colorName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = colorName.folderUIColor
        button.layer.cornerRadius = Layout.colorButtonSize / 2
        button.clipsToBounds = true
        button.tag = availableColors.firstIndex(of: colorName) ?? 0
        button.addTarget(
            self,
            action: #selector(colorTapped(_:)),
            for: .touchUpInside
        )
        
        if colorName == selectedColorName {
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor.label.cgColor
        }
        
        return button
    }
    
    @objc private func colorTapped(_ sender: UIButton) {
        selectedColorName = availableColors[sender.tag]
        
        for case let button as UIButton in colorsStackView.arrangedSubviews {
            button.layer.borderWidth = 0
        }
        
        sender.layer.borderWidth = 3
        sender.layer.borderColor = UIColor.label.cgColor
    }
    
    @objc private func nameChanged() {
        let name = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let isValid = !name.isEmpty
        
        saveButton.isEnabled = isValid
        saveButton.backgroundColor = isValid ? .systemBlue : .systemGray4
    }
    
    @objc private func saveTapped() {
        let name = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !name.isEmpty else {
            return
        }
        
        if let editingFolder {
            let updatedFolder = TripFolder(
                id: editingFolder.id,
                name: name,
                colorName: selectedColorName,
                createdAt: editingFolder.createdAt
            )
            
            onFolderUpdated?(updatedFolder)
        } else {
            let folder = TripFolder(
                id: UUID(),
                name: name,
                colorName: selectedColorName,
                createdAt: Date()
            )
            
            onFolderCreated?(folder)
        }
        
        dismiss(animated: true)
    }
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CreateFolderViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
