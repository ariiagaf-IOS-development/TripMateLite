//
//  AddTripViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 14.05.2026.
//

import UIKit

final class AddTripViewController: UIViewController {
    
    var onTripCreated: ((Trip) -> Void)?
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 24

        static let labelToFieldSpacing: CGFloat = 8
        static let fieldBlockSpacing: CGFloat = 22
        static let sectionTitleSpacing: CGFloat = 32
        static let sectionSpacing: CGFloat = 48

        static let inputHeight: CGFloat = 44
        static let noteHeight: CGFloat = 96
        static let buttonHeight: CGFloat = 50

        static let cornerRadius: CGFloat = 12
        static let textFieldLeftPadding: CGFloat = 16
        static let scrollToButtonSpacing: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 20
    }
    
    private let viewModel = AddTripViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let screenTitleLabel = UILabel()
    private let screenSubtitleLabel = UILabel()
        
    private let destinationLabel = UILabel()
    private let destinationTextField = UITextField()
    
    private let startDateRowView = UIView()
    private let endDateRowView = UIView()
    
    private let startDateLabel = UILabel()
    private let endDateLabel = UILabel()
    
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    private let noteLabel = UILabel()
    private let noteTextView = UITextView()
    
    private let saveButton = UIButton(type: .system)
    
    private let notePlaceholder = "Add a note..."
    
    private let transportTypeLabel = UILabel()
    private let transportTypeTextField = UITextField()

    private let fromLabel = UILabel()
    private let fromTextField = UITextField()

    private let toLabel = UILabel()
    private let toTextField = UITextField()

    private let departureDateRowView = UIView()
    private let arrivalDateRowView = UIView()

    private let departureDateLabel = UILabel()
    private let arrivalDateLabel = UILabel()

    private let departureDatePicker = UIDatePicker()
    private let arrivalDatePicker = UIDatePicker()

    private let companyLabel = UILabel()
    private let companyTextField = UITextField()

    private let bookingNumberLabel = UILabel()
    private let bookingNumberTextField = UITextField()
    
    private let checkInRowView = UIView()
    private let checkOutRowView = UIView()
        
    private let hotelNameLabel = UILabel()
    private let hotelNameTextField = UITextField()
    
    private let addressLabel = UILabel()
    private let addressTextField = UITextField()
    
    private let checkInLabel = UILabel()
    private let checkOutLabel = UILabel()
    
    private let checkInDatePicker = UIDatePicker()
    private let checkOutDatePicker = UIDatePicker()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "TripMate"
        
        setupSaveButton()
        setupScrollView()
        setupStackView()
        setupScreenHeader()
        setupBasicInfoLabel()
        setupDestinationTextField()
        setupDatePickers()
        setupNoteTextView()
        setupTransportDetails()
        setupHotelDetails()
        setupKeyboardDismissGesture()
        setupKeyboardObservers()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -Layout.scrollToButtonSpacing),

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
        stackView.spacing = Layout.labelToFieldSpacing

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.topPadding),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.bottomPadding)
        ])
    }
    
    private func setupScreenHeader() {
        screenTitleLabel.text = "Add Trip"
        screenTitleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        screenTitleLabel.textColor = .label
        
        stackView.addArrangedSubview(screenTitleLabel)
        stackView.addArrangedSubview(screenSubtitleLabel)
        stackView.setCustomSpacing(36, after: screenSubtitleLabel)
    }
    
    private func addDateRow(
        rowView: UIView,
        label: UILabel,
        picker: UIDatePicker,
        title: String,
        mode: UIDatePicker.Mode
    ) {
        configureFieldLabel(label, text: title)
        
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .compact
        
        setupDateRow(rowView, label: label, picker: picker)
        
        stackView.addArrangedSubview(rowView)
        rowView.heightAnchor.constraint(equalToConstant: Layout.inputHeight).isActive = true
        stackView.setCustomSpacing(Layout.fieldBlockSpacing, after: rowView)
    }
    
    private func addSectionHeader(title: String, emoji: String) {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        
        container.addSubview(titleLabel)
        container.addSubview(emojiLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            emojiLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        stackView.addArrangedSubview(container)
        stackView.setCustomSpacing(Layout.sectionTitleSpacing, after: container)
    }
    
    private func configureFieldLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.autocapitalizationType = .words
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.layer.cornerRadius = Layout.cornerRadius
        textField.clipsToBounds = true
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: Layout.textFieldLeftPadding,
                height: Layout.inputHeight
            )
        )
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.heightAnchor.constraint(equalToConstant: Layout.inputHeight).isActive = true
    }
    
    private func addTextFieldBlock(
        label: UILabel,
        textField: UITextField,
        title: String,
        placeholder: String
    ) {
        configureFieldLabel(label, text: title)
        configureTextField(textField, placeholder: placeholder)
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(textField)
        
        stackView.setCustomSpacing(Layout.fieldBlockSpacing, after: textField)
    }
    
    private func setupBasicInfoLabel() {
        addSectionHeader(title: "Basic Trip Info", emoji: "🧳")
    }
    
    private func setupDestinationTextField() {
        addTextFieldBlock(
            label: destinationLabel,
            textField: destinationTextField,
            title: "Destination",
            placeholder: "e.g. Rome"
        )
    }
    
    private func setupDatePickers() {
        addDateRow(
            rowView: startDateRowView,
            label: startDateLabel,
            picker: startDatePicker,
            title: "Start Date",
            mode: .date
        )
        
        addDateRow(
            rowView: endDateRowView,
            label: endDateLabel,
            picker: endDatePicker,
            title: "End Date",
            mode: .date
        )
    }
    
    private func setupDateRow(_ rowView: UIView, label: UILabel, picker: UIDatePicker) {
        rowView.addSubview(label)
        rowView.addSubview(picker)

        label.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 160),

            picker.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            picker.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
        ])
    }
    
    private func setupNoteTextView() {
        configureFieldLabel(noteLabel, text: "Note")
        
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .placeholderText
        noteTextView.delegate = self
        
        noteTextView.font = .systemFont(ofSize: 16)
        noteTextView.backgroundColor = .white
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = UIColor.systemGray5.cgColor
        noteTextView.layer.cornerRadius = Layout.cornerRadius
        noteTextView.clipsToBounds = true
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        stackView.addArrangedSubview(noteLabel)
        stackView.addArrangedSubview(noteTextView)

        noteTextView.heightAnchor.constraint(equalToConstant: Layout.noteHeight).isActive = true
    }
    
    private func setupTransportDetails() {
        stackView.setCustomSpacing(Layout.sectionSpacing, after: noteTextView)
        
        addSectionHeader(title: "Transport Details", emoji: "🚆")
        
        addTextFieldBlock(
            label: transportTypeLabel,
            textField: transportTypeTextField,
            title: "Transport Type",
            placeholder: "Plane / Train / Bus / Car"
        )
        
        addTextFieldBlock(
            label: fromLabel,
            textField: fromTextField,
            title: "From",
            placeholder: "e.g. Belgrade"
        )
        
        addTextFieldBlock(
            label: toLabel,
            textField: toTextField,
            title: "To",
            placeholder: "e.g. Rome"
        )
        
        addDateRow(
            rowView: departureDateRowView,
            label: departureDateLabel,
            picker: departureDatePicker,
            title: "Departure",
            mode: .dateAndTime
        )

        addDateRow(
            rowView: arrivalDateRowView,
            label: arrivalDateLabel,
            picker: arrivalDatePicker,
            title: "Arrival",
            mode: .dateAndTime
        )
        
        addTextFieldBlock(
            label: companyLabel,
            textField: companyTextField,
            title: "Company",
            placeholder: "e.g. Air Serbia / FlixBus"
        )
        
        addTextFieldBlock(
            label: bookingNumberLabel,
            textField: bookingNumberTextField,
            title: "Booking / Route Number",
            placeholder: "e.g. JU532 / 1234"
        )
    }
    
    private func setupHotelDetails() {
        stackView.setCustomSpacing(Layout.sectionSpacing, after: bookingNumberTextField)
        
        addSectionHeader(title: "Hotel Details", emoji: "🏨")
        
        addTextFieldBlock(
            label: hotelNameLabel,
            textField: hotelNameTextField,
            title: "Hotel Name",
            placeholder: "e.g. Roma Center Hotel"
        )
        
        addTextFieldBlock(
            label: addressLabel,
            textField: addressTextField,
            title: "Address",
            placeholder: "e.g. Via Roma 12"
        )
        
        addDateRow(
            rowView: checkInRowView,
            label: checkInLabel,
            picker: checkInDatePicker,
            title: "Check-in",
            mode: .dateAndTime
        )
        
        addDateRow(
            rowView: checkOutRowView,
            label: checkOutLabel,
            picker: checkOutDatePicker,
            title: "Check-out",
            mode: .dateAndTime
        )
    }
    
    private func setupSaveButton() {
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Trip", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = Layout.cornerRadius
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalPadding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalPadding),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.buttonBottomPadding),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
        
        view.bringSubviewToFront(saveButton)
    }
    
    @objc private func saveButtonTapped() {
        let destination = destinationTextField.text ?? ""
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let note = noteTextView.textColor == .placeholderText ? "" : noteTextView.text ?? ""
        let transportType = transportTypeTextField.text ?? ""
        let from = fromTextField.text ?? ""
        let to = toTextField.text ?? ""
        let departureDate = departureDatePicker.date
        let arrivalDate = arrivalDatePicker.date
        let company = companyTextField.text ?? ""
        let bookingNumber = bookingNumberTextField.text ?? ""
        let hotelName = hotelNameTextField.text ?? ""
        let address = addressTextField.text ?? ""
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        
        let result = viewModel.makeTrip(
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            note: note,
            transportType: transportType,
            from: from,
            to: to,
            departureDate: departureDate,
            arrivalDate: arrivalDate,
            company: company,
            bookingNumber: bookingNumber,
            hotelName: hotelName,
            address: address,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate
        )
        
        switch result {
        case .success(let trip):
            onTripCreated?(trip)
            navigationController?.popViewController(animated: true)

        case .failure(let message):
            showAlert(message: message)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Invalid data",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        
        let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom + 16
        
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AddTripViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = notePlaceholder
            textView.textColor = .placeholderText
        }
    }
}
