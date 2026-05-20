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

        static let buttonHeight: CGFloat = 50

        static let cornerRadius: CGFloat = 12
        static let scrollToButtonSpacing: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 20
    }
    
    private let viewModel = AddTripViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let screenTitleLabel = UILabel()
    private let screenSubtitleLabel = UILabel()
    
    private let destinationInput = FormTextFieldView(
        title: "Destination",
        placeholder: "e.g. Rome"
    )
    
    private let transportTypeInput = FormTextFieldView(
        title: "Transport Type",
        placeholder: "Plane / Train / Bus / Car"
    )

    private let fromInput = FormTextFieldView(
        title: "From",
        placeholder: "e.g. Belgrade"
    )

    private let toInput = FormTextFieldView(
        title: "To",
        placeholder: "e.g. Rome"
    )

    private let companyInput = FormTextFieldView(
        title: "Company",
        placeholder: "e.g. Air Serbia / FlixBus"
    )

    private let bookingNumberInput = FormTextFieldView(
        title: "Booking / Route Number",
        placeholder: "e.g. JU532 / 1234"
    )

    private let hotelNameInput = FormTextFieldView(
        title: "Hotel Name",
        placeholder: "e.g. Roma Center Hotel"
    )

    private let addressInput = FormTextFieldView(
        title: "Address",
        placeholder: "e.g. Via Roma 12"
    )
    
    private let startDateRow = FormDateRowView(
        title: "Start Date",
        mode: .date
    )

    private let endDateRow = FormDateRowView(
        title: "End Date",
        mode: .date
    )
    
    private let noteInput = FormTextView(
        title: "Note",
        placeholder: "Add a note..."
    )
    
    private let saveButton = UIButton(type: .system)
    
    private let departureDateRow = FormDateRowView(
        title: "Departure",
        mode: .dateAndTime
    )

    private let arrivalDateRow = FormDateRowView(
        title: "Arrival",
        mode: .dateAndTime
    )

    private let checkInDateRow = FormDateRowView(
        title: "Check-in",
        mode: .dateAndTime
    )

    private let checkOutDateRow = FormDateRowView(
        title: "Check-out",
        mode: .dateAndTime
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground
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
        
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: saveButton.topAnchor,
                constant: -Layout.scrollToButtonSpacing
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
        stackView.spacing = Layout.labelToFieldSpacing

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
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.bottomPadding
            )
        ])
    }
    
    private func setupScreenHeader() {
        screenTitleLabel.text = "Add Trip"
        screenTitleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        screenTitleLabel.textColor = .label
        
        screenSubtitleLabel.text = ""
        
        stackView.addArrangedSubview(screenTitleLabel)
        stackView.addArrangedSubview(screenSubtitleLabel)
        stackView.setCustomSpacing(36, after: screenSubtitleLabel)
    }
    
    private func setupBasicInfoLabel() {
        addSectionHeader(title: "Basic Trip Info", emoji: "🧳")
    }
    
    private func setupDestinationTextField() {
        addInputBlock(destinationInput)
    }
    
    private func setupDatePickers() {
        addDateInputBlock(startDateRow)
        addDateInputBlock(endDateRow)
    }
    
    private func setupNoteTextView() {
        stackView.addArrangedSubview(noteInput)
        stackView.setCustomSpacing(Layout.fieldBlockSpacing, after: noteInput)
    }
    
    private func setupTransportDetails() {
        stackView.setCustomSpacing(Layout.sectionSpacing, after: noteInput)
        
        addSectionHeader(title: "Transport Details", emoji: "🚆")
        
        addInputBlock(transportTypeInput)
        addInputBlock(fromInput)
        addInputBlock(toInput)
        
        addDateInputBlock(departureDateRow)
        addDateInputBlock(arrivalDateRow)
        
        addInputBlock(companyInput)
        addInputBlock(bookingNumberInput)
    }
    
    private func setupHotelDetails() {
        stackView.setCustomSpacing(Layout.sectionSpacing, after: bookingNumberInput)
        
        addSectionHeader(title: "Hotel Details", emoji: "🏨")
        
        addInputBlock(hotelNameInput)
        addInputBlock(addressInput)
        
        addDateInputBlock(checkInDateRow)
        addDateInputBlock(checkOutDateRow)
    }
    
    private func addInputBlock(_ inputView: FormTextFieldView) {
        stackView.addArrangedSubview(inputView)
        stackView.setCustomSpacing(Layout.fieldBlockSpacing, after: inputView)
    }
    
    private func addDateInputBlock(_ dateRowView: FormDateRowView) {
        stackView.addArrangedSubview(dateRowView)
        stackView.setCustomSpacing(Layout.fieldBlockSpacing, after: dateRowView)
    }
    
    private func addSectionHeader(title: String, emoji: String) {
        let headerView = SectionHeaderView(title: title, emoji: emoji)
        stackView.addArrangedSubview(headerView)
        stackView.setCustomSpacing(Layout.sectionTitleSpacing, after: headerView)
    }
    
    private func setupSaveButton() {
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Trip", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = Layout.cornerRadius
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
        
        view.bringSubviewToFront(saveButton)
    }
    
    @objc private func saveButtonTapped() {
        let destination = destinationInput.text
        let startDate = startDateRow.date
        let endDate = endDateRow.date
        let note = noteInput.text
        
        let transportType = transportTypeInput.text
        let from = fromInput.text
        let to = toInput.text
        let departureDate = departureDateRow.date
        let arrivalDate = arrivalDateRow.date
        let company = companyInput.text
        let bookingNumber = bookingNumberInput.text
        
        let hotelName = hotelNameInput.text
        let address = addressInput.text
        let checkInDate = checkInDateRow.date
        let checkOutDate = checkOutDateRow.date
        
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
