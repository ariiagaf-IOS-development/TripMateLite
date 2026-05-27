//
//  AddActivityViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

final class AddActivityViewController: UIViewController {
    
    private var isReturnRouteEnabled = false
    private let returnRouteActionButton = UIButton(type: .system)
    private let returnRouteSectionStackView = UIStackView()
    
    private let departurePlaceTextField = UITextField()
    private let arrivalPlaceTextField = UITextField()

    private let returnDeparturePlaceTextField = UITextField()
    private let returnArrivalPlaceTextField = UITextField()

    private let returnTransportTypeTextField = UITextField()
    private let returnFromTextField = UITextField()
    private let returnToTextField = UITextField()
    private let returnDepartureDatePicker = UIDatePicker()
    private let returnArrivalDatePicker = UIDatePicker()
    private let returnCompanyTextField = UITextField()
    private let returnBookingNumberTextField = UITextField()
    
    private var isTimeEnabled = false
    private let timeActionButton = UIButton(type: .system)
    
    private var isRouteDetailsEnabled = false
    private let routeActionButton = UIButton(type: .system)
    
    private var initialFormSnapshot = ""
    private var shouldShowTitleError = false
        
    var onActivityCreated: ((TripActivity) -> Void)?
    var onActivityUpdated: ((TripActivity) -> Void)?
    
    var onActivityDeleted: ((TripActivity) -> Void)?

    private let editingActivity: TripActivity?
    
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 24
        static let titleFontSize: CGFloat = 32
        static let sectionSpacing: CGFloat = 28
        static let cardCornerRadius: CGFloat = 20
        static let fieldHorizontalPadding: CGFloat = 16
        static let fieldVerticalPadding: CGFloat = 14
        static let buttonHeight: CGFloat = 56
        static let buttonBottomPadding: CGFloat = 20
        static let buttonCornerRadius: CGFloat = 20
        static let noteHeight: CGFloat = 90
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel()
    
    private let titleTextField = UITextField()
    private let titleErrorLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    
    private let locationTextField = UITextField()
    private let bookingNumberTextField = UITextField()
    private let noteTextView = UITextView()
    
    private let routeSectionStackView = UIStackView()
    
    private let transportTypeTextField = UITextField()
    private let fromTextField = UITextField()
    private let toTextField = UITextField()
    private let departureDatePicker = UIDatePicker()
    private let arrivalDatePicker = UIDatePicker()
    private let companyTextField = UITextField()
    private let routeBookingNumberTextField = UITextField()
    
    private let saveButton = UIButton(type: .system)
    
    private let notePlaceholder = "Meeting point, ticket info, or plan details..."
    
    init(activity: TripActivity? = nil) {
        self.editingActivity = activity
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.editingActivity = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        navigationItem.title = "TripMate"
        
        setupCloseButton()
        setupDeleteButtonIfNeeded()
        setupSaveButton()
        setupScrollView()
        setupStackView()
        setupContent()
        populateFieldsIfNeeded()
        updateTitleError()
        updateSaveButtonState()
        setupKeyboardDismissGesture()
        initialFormSnapshot = makeFormSnapshot()
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    private func setupDeleteButtonIfNeeded() {
        guard editingActivity != nil else {
            return
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteActivityTapped)
        )
        
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }

    @objc private func deleteActivityTapped() {
        let alert = UIAlertController(
            title: "Delete activity?",
            message: "This activity will be removed from your trip.",
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
                      let editingActivity = self.editingActivity else {
                    return
                }
                
                self.onActivityDeleted?(editingActivity)
                self.dismiss(animated: true)
            }
        )
        
        present(alert, animated: true)
    }
    
    @objc private func closeTapped() {
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
        let title = titleTextField.text ?? ""
        let date = snapshotDate(datePicker.date)
        let hasTime = String(isTimeEnabled)
        let time = isTimeEnabled ? snapshotTime(timePicker.date) : ""
        
        let location = locationTextField.text ?? ""
        let bookingNumber = bookingNumberTextField.text ?? ""
        let note = noteTextView.textColor == .placeholderText ? "" : noteTextView.text ?? ""
        
        let hasRouteDetails = String(isRouteDetailsEnabled)
        let transportType = transportTypeTextField.text ?? ""
        let from = fromTextField.text ?? ""
        let to = toTextField.text ?? ""
        let departurePlace = departurePlaceTextField.text ?? ""
        let arrivalPlace = arrivalPlaceTextField.text ?? ""
        let departureDate = isRouteDetailsEnabled
        ? snapshotDateTime(departureDatePicker.date)
        : ""

        let arrivalDate = isRouteDetailsEnabled
        ? snapshotDateTime(arrivalDatePicker.date)
        : ""
        let company = companyTextField.text ?? ""
        let routeBookingNumber = routeBookingNumberTextField.text ?? ""
        
        let hasReturnRoute = String(isReturnRouteEnabled)
        let returnTransportType = returnTransportTypeTextField.text ?? ""
        let returnFrom = returnFromTextField.text ?? ""
        let returnTo = returnToTextField.text ?? ""
        let returnDeparturePlace = returnDeparturePlaceTextField.text ?? ""
        let returnArrivalPlace = returnArrivalPlaceTextField.text ?? ""

        let returnDepartureDate = isReturnRouteEnabled
        ? snapshotDateTime(returnDepartureDatePicker.date)
        : ""

        let returnArrivalDate = isReturnRouteEnabled
        ? snapshotDateTime(returnArrivalDatePicker.date)
        : ""

        let returnCompany = returnCompanyTextField.text ?? ""
        let returnBookingNumber = returnBookingNumberTextField.text ?? ""
        
        let parts: [String] = [
            title,
            date,
            hasTime,
            time,
            location,
            bookingNumber,
            note,
            hasRouteDetails,
            transportType,
            from,
            to,
            departurePlace,
            arrivalPlace,
            departureDate,
            arrivalDate,
            company,
            routeBookingNumber,
            hasReturnRoute,
            returnTransportType,
            returnFrom,
            returnTo,
            returnDeparturePlace,
            returnArrivalPlace,
            returnDepartureDate,
            returnArrivalDate,
            returnCompany,
            returnBookingNumber
        ]
        
        return parts.joined(separator: "###")
    }
    
    private func snapshotDate(_ date: Date) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )
        
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private func snapshotTime(_ date: Date) -> String {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: date
        )
        
        return "\(components.hour ?? 0)-\(components.minute ?? 0)"
    }

    private func snapshotDateTime(_ date: Date) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)-\(components.hour ?? 0)-\(components.minute ?? 0)"
    }

    private func showDiscardChangesAlert() {
        let alert = UIAlertController(
            title: "Discard changes?",
            message: "Your activity details will not be saved.",
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
    
    private func setupSaveButton() {
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = editingActivity == nil ? "Save Activity" : "Update Activity"
        saveButton.setTitle(buttonTitle, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = Layout.buttonCornerRadius
        
        saveButton.addTarget(
            self,
            action: #selector(saveTapped),
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

    private func updateSaveButtonState() {
        let title = titleTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let isValid = !title.isEmpty
        
        saveButton.isEnabled = true
        saveButton.backgroundColor = isValid ? .systemBlue : .systemGray4
        saveButton.alpha = isValid ? 1.0 : 0.85
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            
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
    
    @objc private func titleChanged() {
        let title = titleTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !title.isEmpty {
            shouldShowTitleError = false
        }
        
        updateTitleError()
        updateSaveButtonState()
    }
    
    private func updateTitleError() {
        titleErrorLabel.isHidden = !shouldShowTitleError
    }
    
    private func setupContent() {
        titleLabel.text = editingActivity == nil ? "Add Activity" : "Edit Activity"
        titleLabel.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        
        titleTextField.addTarget(
            self,
            action: #selector(titleChanged),
            for: .editingChanged
        )
        
        setupDatePicker(datePicker, mode: .date)
        setupDatePicker(timePicker, mode: .time)
        setupDatePicker(departureDatePicker, mode: .dateAndTime)
        setupDatePicker(arrivalDatePicker, mode: .dateAndTime)
        setupDatePicker(returnDepartureDatePicker, mode: .dateAndTime)
        setupDatePicker(returnArrivalDatePicker, mode: .dateAndTime)
        
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .placeholderText
        noteTextView.delegate = self
        noteTextView.font = .systemFont(ofSize: 16, weight: .medium)
        noteTextView.backgroundColor = .clear
        noteTextView.textContainerInset = .zero
        noteTextView.textContainer.lineFragmentPadding = 0
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(makeBasicSection())
        stackView.addArrangedSubview(makeRouteSection())
        stackView.addArrangedSubview(makeReturnRouteSection())
    }
    
    private func makeReturnRouteSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Return Route")
        
        returnRouteSectionStackView.axis = .vertical
        returnRouteSectionStackView.spacing = 12
        
        updateReturnRouteSection()
        
        sectionStack.addArrangedSubview(returnRouteSectionStackView)
        return sectionStack
    }
    
    private func updateReturnRouteSection() {
        returnRouteSectionStackView.arrangedSubviews.forEach { view in
            returnRouteSectionStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if isReturnRouteEnabled {
            let card = makeCard()
            
            card.addArrangedSubview(
                makeCardHeader(
                    title: "Return Route",
                    action: #selector(removeReturnRouteTapped)
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTextFieldBlock(
                    title: "Transport Type",
                    textField: returnTransportTypeTextField,
                    placeholder: "Train / Bus / Taxi"
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftView: makeTextFieldBlock(
                        title: "From",
                        textField: returnFromTextField,
                        placeholder: "Florence"
                    ),
                    rightView: makeTextFieldBlock(
                        title: "To",
                        textField: returnToTextField,
                        placeholder: "Rome"
                    )
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftView: makeTextFieldBlock(
                        title: "From station / airport",
                        textField: returnDeparturePlaceTextField,
                        placeholder: "Firenze SMN / FLR"
                    ),
                    rightView: makeTextFieldBlock(
                        title: "To station / airport",
                        textField: returnArrivalPlaceTextField,
                        placeholder: "Roma Termini / FCO"
                    )
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(makeDateBlock(title: "Departure", picker: returnDepartureDatePicker))
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(makeDateBlock(title: "Arrival", picker: returnArrivalDatePicker))
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftView: makeTextFieldBlock(
                        title: "Company",
                        textField: returnCompanyTextField,
                        placeholder: "Trenitalia"
                    ),
                    rightView: makeTextFieldBlock(
                        title: "Booking No.",
                        textField: returnBookingNumberTextField,
                        placeholder: "TR456"
                    )
                )
            )
            
            returnRouteSectionStackView.addArrangedSubview(card)
        } else {
            returnRouteSectionStackView.addArrangedSubview(
                makeActionButton(
                    button: returnRouteActionButton,
                    title: "Add return route",
                    action: #selector(addReturnRouteTapped)
                )
            )
        }
    }
    
    @objc private func addReturnRouteTapped() {
        isReturnRouteEnabled = true
        
        returnDepartureDatePicker.date = arrivalDatePicker.date
        returnArrivalDatePicker.date = Calendar.current.date(
            byAdding: .hour,
            value: 2,
            to: arrivalDatePicker.date
        ) ?? arrivalDatePicker.date
        
        returnFromTextField.text = toTextField.text
        returnToTextField.text = fromTextField.text
        returnDeparturePlaceTextField.text = arrivalPlaceTextField.text
        returnArrivalPlaceTextField.text = departurePlaceTextField.text
        
        updateReturnRouteSection()
    }

    @objc private func removeReturnRouteTapped() {
        isReturnRouteEnabled = false
        
        returnTransportTypeTextField.text = ""
        returnFromTextField.text = ""
        returnToTextField.text = ""
        returnDeparturePlaceTextField.text = ""
        returnArrivalPlaceTextField.text = ""
        returnCompanyTextField.text = ""
        returnBookingNumberTextField.text = ""
        
        updateReturnRouteSection()
    }
    
    private func populateFieldsIfNeeded() {
        guard let activity = editingActivity else {
            return
        }
        
        titleTextField.text = activity.title
        datePicker.date = activity.date
        
        isTimeEnabled = activity.hasTime
        timePicker.date = activity.time
        
        locationTextField.text = activity.location
        bookingNumberTextField.text = activity.bookingNumber
        
        if !activity.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            noteTextView.text = activity.note
            noteTextView.textColor = .label
        }
        
        isRouteDetailsEnabled = activity.hasRouteDetails
        
        transportTypeTextField.text = activity.routeDetails.transportType
        fromTextField.text = activity.routeDetails.from
        toTextField.text = activity.routeDetails.to
        departurePlaceTextField.text = activity.routeDetails.departurePlace
        arrivalPlaceTextField.text = activity.routeDetails.arrivalPlace
        departureDatePicker.date = activity.routeDetails.departureDate
        arrivalDatePicker.date = activity.routeDetails.arrivalDate
        companyTextField.text = activity.routeDetails.company
        routeBookingNumberTextField.text = activity.routeDetails.bookingNumber
        isReturnRouteEnabled = activity.hasReturnRoute

        returnTransportTypeTextField.text = activity.returnRouteDetails.transportType
        returnFromTextField.text = activity.returnRouteDetails.from
        returnToTextField.text = activity.returnRouteDetails.to
        returnDeparturePlaceTextField.text = activity.returnRouteDetails.departurePlace
        returnArrivalPlaceTextField.text = activity.returnRouteDetails.arrivalPlace
        returnDepartureDatePicker.date = activity.returnRouteDetails.departureDate
        returnArrivalDatePicker.date = activity.returnRouteDetails.arrivalDate
        returnCompanyTextField.text = activity.returnRouteDetails.company
        returnBookingNumberTextField.text = activity.returnRouteDetails.bookingNumber

        updateRouteSection()
        updateReturnRouteSection()
        updateSaveButtonState()
    }
    
    private func makeBasicSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Activity Info")
        let card = makeCard()
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Title *",
                textField: titleTextField,
                placeholder: "Vatican Museum Tour"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(makeDateTimeBlock())

        if !isTimeEnabled {
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(
                makeActionButton(
                    button: timeActionButton,
                    title: "Add time",
                    action: #selector(addTimeTapped)
                )
            )
        }

        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Location",
                textField: locationTextField,
                placeholder: "Vatican City"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Booking No.",
                textField: bookingNumberTextField,
                placeholder: "VM12345"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(makeNoteBlock())
        
        sectionStack.addArrangedSubview(card)
        return sectionStack
    }
    
    @objc private func addTimeTapped() {
        isTimeEnabled = true
        timePicker.date = Date()
        reloadBasicSection()
    }

    @objc private func removeTimeTapped() {
        isTimeEnabled = false
        reloadBasicSection()
    }
    
    private func reloadBasicSection() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(makeBasicSection())
        stackView.addArrangedSubview(makeRouteSection())
        stackView.addArrangedSubview(makeReturnRouteSection())
    }
    
    private func makeDateTimeBlock() -> UIView {
        let container = UIView()
        
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 0
        rowStack.distribution = .fill
        
        let dateBlock = makeDateBlock(
            title: "Date",
            picker: datePicker
        )
        
        rowStack.addArrangedSubview(dateBlock)
        
        if isTimeEnabled {
            let separator = UIView()
            separator.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8)
            
            let timeBlock = makeTimePickerBlock()
            
            rowStack.addArrangedSubview(separator)
            rowStack.addArrangedSubview(timeBlock)
            
            separator.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
            dateBlock.widthAnchor.constraint(equalTo: timeBlock.widthAnchor).isActive = true
        }
        
        container.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: container.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func makeTimePickerBlock() -> UIView {
        let container = UIView()
        
        let titleLabel = makeFieldTitleLabel("Time")
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(
            UIImage(systemName: "minus.circle.fill"),
            for: .normal
        )
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(
            self,
            action: #selector(removeTimeTapped),
            for: .touchUpInside
        )
        
        container.addSubview(titleLabel)
        container.addSubview(deleteButton)
        container.addSubview(timePicker)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            
            deleteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            
            timePicker.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            timePicker.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timePicker.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            )
        ])
        
        return container
    }
    
    private func makeRouteSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Route Details")
        
        routeSectionStackView.axis = .vertical
        routeSectionStackView.spacing = 12
        
        updateRouteSection()
        
        sectionStack.addArrangedSubview(routeSectionStackView)
        return sectionStack
    }
    
    private func updateRouteSection() {
        routeSectionStackView.arrangedSubviews.forEach { view in
            routeSectionStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if isRouteDetailsEnabled {
            let card = makeCard()
            
            card.addArrangedSubview(
                makeCardHeader(
                    title: "Route Details",
                    action: #selector(removeRouteDetailsTapped)
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTextFieldBlock(
                    title: "Transport Type",
                    textField: transportTypeTextField,
                    placeholder: "Train / Bus / Tour"
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftView: makeTextFieldBlock(
                        title: "From",
                        textField: fromTextField,
                        placeholder: "Rome"
                    ),
                    rightView: makeTextFieldBlock(
                        title: "To",
                        textField: toTextField,
                        placeholder: "Florence"
                    )
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftView: makeTextFieldBlock(
                        title: "From station / airport",
                        textField: departurePlaceTextField,
                        placeholder: "Roma Termini / FCO"
                    ),
                    rightView: makeTextFieldBlock(
                        title: "To station / airport",
                        textField: arrivalPlaceTextField,
                        placeholder: "Firenze SMN / FLR"
                    )
                )
            )
            
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(makeDateBlock(title: "Departure", picker: departureDatePicker))
            card.addArrangedSubview(makeSeparator())
            card.addArrangedSubview(makeDateBlock(title: "Arrival", picker: arrivalDatePicker))
            card.addArrangedSubview(makeSeparator())
            
            card.addArrangedSubview(
                makeTwoColumnRow(
                    leftView: makeTextFieldBlock(
                        title: "Company",
                        textField: companyTextField,
                        placeholder: "Trenitalia"
                    ),
                    rightView: makeTextFieldBlock(
                        title: "Booking No.",
                        textField: routeBookingNumberTextField,
                        placeholder: "TR123"
                    )
                )
            )
            
            routeSectionStackView.addArrangedSubview(card)
        } else {
            routeSectionStackView.addArrangedSubview(
                makeActionButton(
                    button: routeActionButton,
                    title: "Add route details",
                    action: #selector(addRouteDetailsTapped)
                )
            )
        }
    }
    
    @objc private func addRouteDetailsTapped() {
        isRouteDetailsEnabled = true
        
        departureDatePicker.date = datePicker.date
        arrivalDatePicker.date = Calendar.current.date(
            byAdding: .hour,
            value: 2,
            to: datePicker.date
        ) ?? datePicker.date
        
        updateRouteSection()
    }

    @objc private func removeRouteDetailsTapped() {
        isRouteDetailsEnabled = false
        
        transportTypeTextField.text = ""
        fromTextField.text = ""
        toTextField.text = ""
        departurePlaceTextField.text = ""
        arrivalPlaceTextField.text = ""
        companyTextField.text = ""
        routeBookingNumberTextField.text = ""
        
        updateRouteSection()
    }
    
    private func makeActionButton(
        button: UIButton,
        title: String,
        action: Selector
    ) -> UIView {
        let container = UIView()
        
        let iconImageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .systemBlue
        
        button.backgroundColor = .clear
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(button)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 10
            ),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func makeCardHeader(title: String, action: Selector) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        let deleteButton = UIButton(type: .system)
        let trashConfig = UIImage.SymbolConfiguration(
            pointSize: 16,
            weight: .semibold
        )
        
        deleteButton.setImage(
            UIImage(systemName: "trash", withConfiguration: trashConfig),
            for: .normal
        )
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )
        
        container.addSubview(titleLabel)
        container.addSubview(deleteButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            ),
            
            deleteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            deleteButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor,
                constant: 12
            ),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return container
    }
    
    private func shakeView(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.35
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        view.layer.add(animation, forKey: "shake")
    }
    
    @objc private func saveTapped() {
        let title = titleTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !title.isEmpty else {
            shouldShowTitleError = true
            updateTitleError()
            updateSaveButtonState()
            return
        }
        
        if isRouteDetailsEnabled && arrivalDatePicker.date < departureDatePicker.date {
            showAlert(message: "Arrival date must be after departure date.")
            return
        }
        
        if isReturnRouteEnabled && returnArrivalDatePicker.date < returnDepartureDatePicker.date {
            showAlert(message: "Return arrival date must be after return departure date.")
            return
        }
        
        let note = noteTextView.textColor == .placeholderText ? "" : noteTextView.text ?? ""
        
        let routeDetails = TransportSegment(
            id: editingActivity?.routeDetails.id ?? UUID(),
            transportType: transportTypeTextField.text ?? "",
            from: fromTextField.text ?? "",
            to: toTextField.text ?? "",
            departurePlace: departurePlaceTextField.text ?? "",
            arrivalPlace: arrivalPlaceTextField.text ?? "",
            departureDate: departureDatePicker.date,
            arrivalDate: arrivalDatePicker.date,
            company: companyTextField.text ?? "",
            bookingNumber: routeBookingNumberTextField.text ?? ""
        )
        
        let returnRouteDetails = TransportSegment(
            id: editingActivity?.returnRouteDetails.id ?? UUID(),
            transportType: returnTransportTypeTextField.text ?? "",
            from: returnFromTextField.text ?? "",
            to: returnToTextField.text ?? "",
            departurePlace: returnDeparturePlaceTextField.text ?? "",
            arrivalPlace: returnArrivalPlaceTextField.text ?? "",
            departureDate: returnDepartureDatePicker.date,
            arrivalDate: returnArrivalDatePicker.date,
            company: returnCompanyTextField.text ?? "",
            bookingNumber: returnBookingNumberTextField.text ?? ""
        )
        
        let activity = TripActivity(
            id: editingActivity?.id ?? UUID(),
            title: title,
            date: datePicker.date,
            hasTime: isTimeEnabled,
            time: timePicker.date,
            location: locationTextField.text ?? "",
            note: note,
            bookingNumber: bookingNumberTextField.text ?? "",
            isBooked: !bookingNumberTextField.text.orEmpty.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            hasRouteDetails: isRouteDetailsEnabled,
            routeDetails: routeDetails,
            hasReturnRoute: isReturnRouteEnabled,
            returnRouteDetails: returnRouteDetails
        )
                
        initialFormSnapshot = makeFormSnapshot()
        
        if editingActivity == nil {
            onActivityCreated?(activity)
        } else {
            onActivityUpdated?(activity)
        }

        dismiss(animated: true)
    }
    
    private func makeSectionStack(title: String) -> UIStackView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 12
        
        let label = UILabel()
        label.text = title.uppercased()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        
        sectionStack.addArrangedSubview(label)
        return sectionStack
    }
    
    private func makeCard() -> UIStackView {
        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 0
        card.applyCardStyle()
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
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.textColor = .label
        textField.autocapitalizationType = .words
        
        container.addSubview(titleLabel)
        container.addSubview(textField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        if textField === titleTextField {
            titleErrorLabel.text = "Please enter activity title."
            titleErrorLabel.font = .systemFont(ofSize: 13, weight: .medium)
            titleErrorLabel.textColor = .systemRed
            titleErrorLabel.numberOfLines = 0
            titleErrorLabel.isHidden = true
            
            container.addSubview(titleErrorLabel)
            titleErrorLabel.translatesAutoresizingMaskIntoConstraints = false
            
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
                
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                titleErrorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
                titleErrorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                titleErrorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                titleErrorLabel.bottomAnchor.constraint(
                    equalTo: container.bottomAnchor,
                    constant: -Layout.fieldVerticalPadding
                )
            ])
        } else {
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
                
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                textField.bottomAnchor.constraint(
                    equalTo: container.bottomAnchor,
                    constant: -Layout.fieldVerticalPadding
                )
            ])
        }
        
        return container
    }
    
    private func makeDateBlock(title: String, picker: UIDatePicker) -> UIView {
        let container = UIView()
        let titleLabel = makeFieldTitleLabel(title)
        
        container.addSubview(titleLabel)
        container.addSubview(picker)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.fieldVerticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.fieldHorizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.fieldHorizontalPadding),
            
            picker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.fieldVerticalPadding)
        ])
        
        return container
    }
    
    private func makeNoteBlock() -> UIView {
        let container = UIView()
        let titleLabel = makeFieldTitleLabel("Note")
        
        container.addSubview(titleLabel)
        container.addSubview(noteTextView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.fieldVerticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.fieldHorizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.fieldHorizontalPadding),
            
            noteTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            noteTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.fieldVerticalPadding),
            noteTextView.heightAnchor.constraint(equalToConstant: Layout.noteHeight)
        ])
        
        return container
    }
    
    private func makeTwoColumnRow(leftView: UIView, rightView: UIView) -> UIStackView {
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
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func setupDatePicker(_ picker: UIDatePicker, mode: UIDatePicker.Mode) {
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemBlue
        picker.contentHorizontalAlignment = .leading
        
        picker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
    }
    
    @objc private func datePickerValueChanged(_ picker: UIDatePicker) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            picker.resignFirstResponder()
            self.view.endEditing(true)
            
            if let presentedViewController = self.presentedViewController {
                presentedViewController.dismiss(animated: true)
            }
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
}

extension AddActivityViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Meeting point, ticket info, or plan details..."
            textView.textColor = .placeholderText
        }
    }
}

private extension Optional where Wrapped == String {
    var orEmpty: String {
        self ?? ""
    }
}
