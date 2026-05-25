//
//  ChecklistItemInputViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class ChecklistItemInputViewController: UIViewController {
    
    var onItemAdded: ((String) -> Void)?
    
    private let dimView = UIView()
    private let containerView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    private var containerBottomConstraint: NSLayoutConstraint?
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let containerCornerRadius: CGFloat = 28
        static let topPadding: CGFloat = 10
        static let bottomPadding: CGFloat = 22
        static let buttonHeight: CGFloat = 54
        static let keyboardExtraOffset: CGFloat = 24
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupDimView()
        setupContainer()
        setupHeader()
        setupTextField()
        setupAddButton()
        setupKeyboardObservers()
        updateAddButtonState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.textField.becomeFirstResponder()
        }
    }
    
    private func setupDimView() {
        view.addSubview(dimView)
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = .clear
        
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
        
        containerBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor
        )

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerBottomConstraint!
        ])
    }
    
    private func setupHeader() {
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        handleView.backgroundColor = .systemGray4
        handleView.layer.cornerRadius = 2
        
        titleLabel.text = "New checklist item"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        
        closeButton.setImage(
            UIImage(systemName: "xmark.circle.fill"),
            for: .normal
        )
        closeButton.tintColor = .systemGray3
        closeButton.addTarget(
            self,
            action: #selector(closeTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Layout.topPadding
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
                equalTo: closeButton.leadingAnchor,
                constant: -12
            ),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTextField() {
        containerView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "e.g. Passport"
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 18
        textField.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 1)
        )
        textField.leftViewMode = .always
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        
        textField.delegate = self
        
        textField.addTarget(
            self,
            action: #selector(textChanged),
            for: .editingChanged
        )
        
        textField.addTarget(
            self,
            action: #selector(addTapped),
            for: .editingDidEndOnExit
        )
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 22
            ),
            textField.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            textField.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            textField.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func setupAddButton() {
        containerView.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add Item", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 20
        
        addButton.addTarget(
            self,
            action: #selector(addTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(
                equalTo: textField.bottomAnchor,
                constant: 16
            ),
            addButton.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Layout.horizontalPadding
            ),
            addButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Layout.horizontalPadding
            ),
            addButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            addButton.bottomAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.bottomPadding
            )
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        containerBottomConstraint?.constant = -keyboardHeight + view.safeAreaInsets.bottom - Layout.keyboardExtraOffset
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide() {
        containerBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func textChanged() {
        updateAddButtonState()
    }
    
    private func updateAddButtonState() {
        let title = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let isValid = !title.isEmpty
        
        addButton.isEnabled = isValid
        addButton.backgroundColor = isValid ? .systemBlue : .systemGray4
        addButton.alpha = isValid ? 1.0 : 0.85
    }
    
    @objc private func addTapped() {
        let title = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !title.isEmpty else {
            return
        }
        
        onItemAdded?(title)
        dismiss(animated: true)
    }
    
    @objc private func closeTapped() {
        view.endEditing(true)
        dismiss(animated: true)
    }
}

extension ChecklistItemInputViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTapped()
        return true
    }
}
