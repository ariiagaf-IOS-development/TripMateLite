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
        
        static let titleFontSize: CGFloat = 32
        
        static let sectionSpacing: CGFloat = 32
        static let sectionTitleFontSize: CGFloat = 13
        
        static let cardCornerRadius: CGFloat = 20
        static let fieldHorizontalPadding: CGFloat = 16
        static let fieldVerticalPadding: CGFloat = 14
        static let separatorHeight: CGFloat = 1
        
        static let labelFontSize: CGFloat = 12
        static let inputFontSize: CGFloat = 17
        static let noteHeight: CGFloat = 100
        
        static let buttonHeight: CGFloat = 56
        static let buttonBottomPadding: CGFloat = 20
        static let buttonCornerRadius: CGFloat = 20
    }
    
    private let viewModel = AddTripViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let screenTitleLabel = UILabel()
    
    private let destinationTextField = UITextField()
    private let noteTextView = UITextView()
    
    private let transportTypeTextField = UITextField()
    private let fromTextField = UITextField()
    private let toTextField = UITextField()
    private let companyTextField = UITextField()
    private let bookingNumberTextField = UITextField()
    
    private let hotelNameTextField = UITextField()
    private let addressTextField = UITextField()
    
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let departureDatePicker = UIDatePicker()
    private let arrivalDatePicker = UIDatePicker()
    private let checkInDatePicker = UIDatePicker()
    private let checkOutDatePicker = UIDatePicker()
    
    private let saveButton = UIButton(type: .system)
    
    private let notePlaceholder = "First stop of my Eurotrip..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupCloseButton()
        setupSaveButton()
        setupScrollView()
        setupStackView()
        setupScreenHeader()
        setupContent()
        setupKeyboardDismissGesture()
        setupKeyboardObservers()
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func setupSaveButton() {
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Trip", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = Layout.buttonCornerRadius
        
        saveButton.layer.shadowColor = UIColor.systemBlue.cgColor
        saveButton.layer.shadowOpacity = 0.20
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        saveButton.layer.shadowRadius = 14
        
        saveButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
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
                constant: -Layout.buttonBottomPadding
            ),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
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
        scrollView.keyboardDismissMode = .interactive
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: saveButton.topAnchor,
                constant: -16
            ),
            
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
        stackView.spacing = Layout.sectionSpacing
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Layout.topPadding
            ),
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
    
    private func setupScreenHeader() {
        screenTitleLabel.text = "Add Trip"
        screenTitleLabel.font = .systemFont(
            ofSize: Layout.titleFontSize,
            weight: .bold
        )
        screenTitleLabel.textColor = .label
        
        stackView.addArrangedSubview(screenTitleLabel)
    }
    
    private func setupContent() {
        setupDatePicker(startDatePicker, mode: .date)
        setupDatePicker(endDatePicker, mode: .date)
        setupDatePicker(departureDatePicker, mode: .dateAndTime)
        setupDatePicker(arrivalDatePicker, mode: .dateAndTime)
        setupDatePicker(checkInDatePicker, mode: .dateAndTime)
        setupDatePicker(checkOutDatePicker, mode: .dateAndTime)
        
        setupNoteTextView()
        
        stackView.addArrangedSubview(makeBasicTripInfoSection())
        stackView.addArrangedSubview(makeTransportDetailsSection())
        stackView.addArrangedSubview(makeHotelDetailsSection())
    }
    
    private func makeBasicTripInfoSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Basic Trip Info")
        let card = makeCard()
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Destination",
                textField: destinationTextField,
                placeholder: "e.g. Rome, Italy"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeDateBlock(
                    title: "Start Date",
                    picker: startDatePicker
                ),
                rightView: makeDateBlock(
                    title: "End Date",
                    picker: endDatePicker
                )
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(makeNoteBlock())
        
        sectionStack.addArrangedSubview(card)
        return sectionStack
    }
    
    private func makeTransportDetailsSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Transport Details")
        let card = makeCard()
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Transport Type",
                textField: transportTypeTextField,
                placeholder: "Plane / Train / Bus / Car"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeTextFieldBlock(
                    title: "From",
                    textField: fromTextField,
                    placeholder: "Belgrade"
                ),
                rightView: makeTextFieldBlock(
                    title: "To",
                    textField: toTextField,
                    placeholder: "Rome"
                )
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Departure",
                picker: departureDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Arrival",
                picker: arrivalDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeTextFieldBlock(
                    title: "Company",
                    textField: companyTextField,
                    placeholder: "Air Serbia / Trenitalia"
                ),
                rightView: makeTextFieldBlock(
                    title: "Booking No.",
                    textField: bookingNumberTextField,
                    placeholder: "JU532 / FR9421"
                )
            )
        )
        
        sectionStack.addArrangedSubview(card)
        return sectionStack
    }
    
    private func makeHotelDetailsSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Hotel Details")
        let card = makeCard()
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Hotel Name",
                textField: hotelNameTextField,
                placeholder: "Roma Center Hotel"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Address",
                textField: addressTextField,
                placeholder: "Via Roma 12"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Check-in",
                picker: checkInDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Check-out",
                picker: checkOutDatePicker
            )
        )
        
        sectionStack.addArrangedSubview(card)
        return sectionStack
    }
    
    private func makeSectionStack(title: String) -> UIStackView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(
            ofSize: Layout.sectionTitleFontSize,
            weight: .bold
        )
        titleLabel.textColor = .secondaryLabel
        
        sectionStack.addArrangedSubview(titleLabel)
        return sectionStack
    }
    
    private func makeCard() -> UIStackView {
        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 0
        card.backgroundColor = UIColor.cardBackground
        card.layer.cornerRadius = Layout.cardCornerRadius
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.systemGray5.cgColor
        card.clipsToBounds = true
        
        return card
    }
    
    private func makeTextFieldBlock(
        title: String,
        textField: UITextField,
        placeholder: String
    ) -> UIView {
        let container = UIView()
        let titleLabel = makeFieldTitleLabel(title)
        
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = .systemFont(
            ofSize: Layout.inputFontSize,
            weight: .medium
        )
        textField.textColor = .label
        textField.autocapitalizationType = .words
        
        container.addSubview(titleLabel)
        container.addSubview(textField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            
            textField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 4
            ),
            textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textField.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            )
        ])
        
        return container
    }
    
    private func makeDateBlock(title: String, picker: UIDatePicker) -> UIView {
        let container = UIView()
        let titleLabel = makeFieldTitleLabel(title)
        
        picker.contentHorizontalAlignment = .leading
        
        container.addSubview(titleLabel)
        container.addSubview(picker)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            
            picker.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            picker.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            picker.trailingAnchor.constraint(
                lessThanOrEqualTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            picker.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            )
        ])
        
        return container
    }
    
    private func makeNoteBlock() -> UIView {
        let container = UIView()
        let titleLabel = makeFieldTitleLabel("Notes")
        
        container.addSubview(titleLabel)
        container.addSubview(noteTextView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            
            noteTextView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 6
            ),
            noteTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            noteTextView.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            ),
            noteTextView.heightAnchor.constraint(equalToConstant: Layout.noteHeight)
        ])
        
        return container
    }
    
    private func makeTwoColumnRow(
        leftView: UIView,
        rightView: UIView
    ) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 0
        rowStack.distribution = .fill
        
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8)
        
        rowStack.addArrangedSubview(leftView)
        rowStack.addArrangedSubview(separator)
        rowStack.addArrangedSubview(rightView)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: 0.5),
            leftView.widthAnchor.constraint(equalTo: rightView.widthAnchor)
        ])
        
        return rowStack
    }
    
    private func makeFieldTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(
            ofSize: Layout.labelFontSize,
            weight: .bold
        )
        label.textColor = .secondaryLabel
        return label
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8)
        separator.heightAnchor.constraint(equalToConstant: Layout.separatorHeight).isActive = true
        return separator
    }
    
    private func setupDatePicker(_ picker: UIDatePicker, mode: UIDatePicker.Mode) {
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemBlue
        picker.contentHorizontalAlignment = .leading
    }
    
    private func setupNoteTextView() {
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .placeholderText
        noteTextView.delegate = self
        noteTextView.font = .systemFont(
            ofSize: Layout.inputFontSize,
            weight: .medium
        )
        noteTextView.backgroundColor = .clear
        noteTextView.textContainerInset = .zero
        noteTextView.textContainer.lineFragmentPadding = 0
    }
    
    @objc private func saveButtonTapped() {
        let destination = destinationTextField.text ?? ""
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        let note = noteTextView.textColor == .placeholderText
        ? ""
        : noteTextView.text ?? ""
        
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
            
            if presentingViewController != nil {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
            
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
