//
//  AddTripViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 14.05.2026.
//

import UIKit

final class AddTripViewController: UIViewController {
    
    var onTripCreated: ((Trip) -> Void)?
    var onTripUpdated: ((Trip) -> Void)?
    
    private let editingTrip: Trip?
    
    private struct RouteStepInput {
        let id = UUID()
        let transportTypeTextField = UITextField()
        let fromTextField = UITextField()
        let toTextField = UITextField()
        let departureDatePicker = UIDatePicker()
        let arrivalDatePicker = UIDatePicker()
        let companyTextField = UITextField()
        let bookingNumberTextField = UITextField()
    }
    
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
    
    private let destinationErrorLabel = UILabel()
    private var destinationContainerView: UIView?
    
    private let noteTextView = UITextView()
    
    private var isNoteEnabled = false
    private let noteSectionStackView = UIStackView()
    private let noteActionButton = UIButton(type: .system)
    
    private var routeStepInputs: [RouteStepInput] = []
    private var isRouteDetailsEnabled = false
    private var isMultiStepRouteEnabled = false

    private let routeSectionStackView = UIStackView()
    private let routeStepsStackView = UIStackView()
    private let routeActionButton = UIButton(type: .system)
    private let routeDetailsActionButton = UIButton(type: .system)
    
    private var returnStepInputs: [RouteStepInput] = []
    private var isReturnRouteEnabled = false
    private var isMultiStepReturnRouteEnabled = false

    private let returnRouteSectionStackView = UIStackView()
    private let returnStepsStackView = UIStackView()
    private let returnRouteActionButton = UIButton(type: .system)
    private let returnRouteDetailsActionButton = UIButton(type: .system)
    
    private let hotelNameTextField = UITextField()
    private let addressTextField = UITextField()
    
    private var isHotelDetailsEnabled = false
    private var isHotelDatesEnabled = false
    
    private let hotelSectionStackView = UIStackView()
    private let hotelActionButton = UIButton(type: .system)
    private let hotelDatesActionButton = UIButton(type: .system)
    
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    private var didChangeStartDate = false
    private var didChangeEndDate = false
    
    private let checkInDatePicker = UIDatePicker()
    private let checkOutDatePicker = UIDatePicker()
    
    private let saveButton = UIButton(type: .system)
    
    private let notePlaceholder = "First stop of my Eurotrip..."
    
    init(trip: Trip? = nil) {
        self.editingTrip = trip
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.editingTrip = nil
        super.init(coder: coder)
    }
    
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
        setupDefaultDatesIfNeeded()
        populateFieldsIfNeeded()
        updateSaveButtonState()
        setupKeyboardDismissGesture()
        setupKeyboardObservers()
    }
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    @objc private func closeButtonTapped() {
        if hasUnsavedChanges() {
            showDiscardChangesAlert()
        } else {
            dismiss(animated: true)
        }
    }
    
    private func hasUnsavedChanges() -> Bool {
        if didChangeStartDate || didChangeEndDate {
            return true
        }
        
        let destination = destinationTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !destination.isEmpty {
            return true
        }
        
        if isNoteEnabled && noteTextView.textColor != .placeholderText {
            let note = noteTextView.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if !note.isEmpty {
                return true
            }
        }
        
        let hasRouteChanges = routeStepInputs.contains { input in
            let transportType = input.transportTypeTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let from = input.fromTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let to = input.toTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let company = input.companyTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let bookingNumber = input.bookingNumberTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            return !transportType.isEmpty ||
            !from.isEmpty ||
            !to.isEmpty ||
            !company.isEmpty ||
            !bookingNumber.isEmpty
        }
        
        if isRouteDetailsEnabled || hasRouteChanges {
            return true
        }
        
        let hasReturnRouteChanges = returnStepInputs.contains { input in
            let transportType = input.transportTypeTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let from = input.fromTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let to = input.toTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let company = input.companyTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let bookingNumber = input.bookingNumberTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            return !transportType.isEmpty ||
            !from.isEmpty ||
            !to.isEmpty ||
            !company.isEmpty ||
            !bookingNumber.isEmpty
        }
        
        if isReturnRouteEnabled || hasReturnRouteChanges {
            return true
        }
        
        if isHotelDetailsEnabled {
            let hotelName = hotelNameTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let address = addressTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            return !hotelName.isEmpty || !address.isEmpty || isHotelDatesEnabled
        }
        
        return false
    }

    private func showDiscardChangesAlert() {
        let alert = UIAlertController(
            title: "Discard changes?",
            message: "Your trip details will not be saved.",
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
        let buttonTitle = editingTrip == nil ? "Save Trip" : "Update Trip"
        saveButton.setTitle(buttonTitle, for: .normal)
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
        screenTitleLabel.text = editingTrip == nil ? "Add Trip" : "Edit Trip"
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
        
        startDatePicker.addTarget(
            self,
            action: #selector(startDateChanged),
            for: .valueChanged
        )

        endDatePicker.addTarget(
            self,
            action: #selector(endDateChanged),
            for: .valueChanged
        )
        
        setupDatePicker(checkInDatePicker, mode: .dateAndTime)
        setupDatePicker(checkOutDatePicker, mode: .dateAndTime)
        
        setupNoteTextView()
        
        stackView.addArrangedSubview(makeBasicTripInfoSection())
        stackView.addArrangedSubview(makeRoutePlanSection())
        stackView.addArrangedSubview(makeReturnRouteSection())
        stackView.addArrangedSubview(makeHotelDetailsSection())
    }
    
    private func setupDefaultDatesIfNeeded() {
        guard editingTrip == nil else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        
        startDatePicker.date = now
        endDatePicker.date = tomorrow
        
        checkInDatePicker.date = now
        checkOutDatePicker.date = tomorrow
    }
    
    private func populateFieldsIfNeeded() {
        guard let trip = editingTrip else {
            return
        }
        
        destinationTextField.text = trip.basicInfo.destination
        
        if !trip.basicInfo.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isNoteEnabled = true
            noteTextView.text = trip.basicInfo.note
            noteTextView.textColor = .label
            updateNoteSection()
        }
        
        startDatePicker.date = trip.basicInfo.startDate
        endDatePicker.date = trip.basicInfo.endDate
        didChangeStartDate = true
        didChangeEndDate = true
        
        populateRouteSteps(from: trip)
        populateReturnRoute(from: trip)
        populateHotelDetails(from: trip)
    }
    
    private func populateRouteSteps(from trip: Trip) {
        routeStepInputs.removeAll()
        
        let hasRouteData = trip.routeSteps.contains { step in
            !step.transportType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.bookingNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        guard hasRouteData else {
            isRouteDetailsEnabled = false
            isMultiStepRouteEnabled = false
            updateRouteSection()
            return
        }

        isRouteDetailsEnabled = true
        
        routeStepsStackView.arrangedSubviews.forEach { view in
            routeStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        let steps = trip.routeSteps.isEmpty
        ? [
            TransportSegment(
                id: UUID(),
                transportType: trip.transportDetails.transportType,
                from: trip.transportDetails.from,
                to: trip.transportDetails.to,
                departureDate: trip.transportDetails.departureDate,
                arrivalDate: trip.transportDetails.arrivalDate,
                company: trip.transportDetails.company,
                bookingNumber: trip.transportDetails.bookingNumber
            )
        ]
        : trip.routeSteps
        
        isMultiStepRouteEnabled = steps.count > 1
        routeActionButton.configuration?.title = isMultiStepRouteEnabled
        ? "Add route step"
        : "Create multi-step route"
        
        for step in steps {
            let input = RouteStepInput()
            
            setupDatePicker(input.departureDatePicker, mode: .dateAndTime)
            setupDatePicker(input.arrivalDatePicker, mode: .dateAndTime)
            
            input.transportTypeTextField.text = step.transportType
            input.fromTextField.text = step.from
            input.toTextField.text = step.to
            input.departureDatePicker.date = step.departureDate
            input.arrivalDatePicker.date = step.arrivalDate
            input.companyTextField.text = step.company
            input.bookingNumberTextField.text = step.bookingNumber
            
            routeStepInputs.append(input)
        }
        
        rebuildRouteSteps()
        updateRouteSection()
    }
    
    private func populateReturnRoute(from trip: Trip) {
        returnStepInputs.removeAll()
        
        let hasReturnRouteData = trip.returnRouteSteps.contains { step in
            !step.transportType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !step.bookingNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        guard trip.hasReturnTicket && hasReturnRouteData else {
            isReturnRouteEnabled = false
            isMultiStepReturnRouteEnabled = false
            updateReturnRouteSection()
            return
        }
        
        isReturnRouteEnabled = true
        isMultiStepReturnRouteEnabled = trip.returnRouteSteps.count > 1
        
        returnStepsStackView.arrangedSubviews.forEach { view in
            returnStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for step in trip.returnRouteSteps {
            let input = RouteStepInput()
            
            setupDatePicker(input.departureDatePicker, mode: .dateAndTime)
            setupDatePicker(input.arrivalDatePicker, mode: .dateAndTime)
            
            input.transportTypeTextField.text = step.transportType
            input.fromTextField.text = step.from
            input.toTextField.text = step.to
            input.departureDatePicker.date = step.departureDate
            input.arrivalDatePicker.date = step.arrivalDate
            input.companyTextField.text = step.company
            input.bookingNumberTextField.text = step.bookingNumber
            
            returnStepInputs.append(input)
        }
        
        returnRouteActionButton.configuration?.title = isMultiStepReturnRouteEnabled
        ? "Add return step"
        : "Create multi-step return route"
        
        rebuildReturnSteps()
        updateReturnRouteSection()
    }
    
    private func populateHotelDetails(from trip: Trip) {
        isHotelDetailsEnabled = trip.hasHotelDetails
        isHotelDatesEnabled = trip.hasHotelDates
        
        if trip.hasHotelDetails {
            hotelNameTextField.text = trip.hotelDetails.hotelName
            addressTextField.text = trip.hotelDetails.address
        } else {
            hotelNameTextField.text = ""
            addressTextField.text = ""
        }
        
        if trip.hasHotelDates {
            checkInDatePicker.date = trip.hotelDetails.checkInDate
            checkOutDatePicker.date = trip.hotelDetails.checkOutDate
        }
        
        updateHotelSection()
    }
    
    @objc private func startDateChanged() {
        didChangeStartDate = true
        
        let nextDay = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: startDatePicker.date
        ) ?? startDatePicker.date
        
        endDatePicker.date = nextDay
        didChangeEndDate = true
        
        if isRouteDetailsEnabled {
            for input in routeStepInputs {
                input.departureDatePicker.date = startDatePicker.date
                input.arrivalDatePicker.date = Calendar.current.date(
                    byAdding: .hour,
                    value: 2,
                    to: startDatePicker.date
                ) ?? startDatePicker.date
            }
        }
        
        if isReturnRouteEnabled {
            for input in returnStepInputs {
                input.departureDatePicker.date = endDatePicker.date
                input.arrivalDatePicker.date = Calendar.current.date(
                    byAdding: .hour,
                    value: 2,
                    to: endDatePicker.date
                ) ?? endDatePicker.date
            }
        }
        
        if isHotelDetailsEnabled && isHotelDatesEnabled {
            checkInDatePicker.date = startDatePicker.date
            checkOutDatePicker.date = endDatePicker.date
        }
    }

    @objc private func endDateChanged() {
        didChangeEndDate = true
        
        if isReturnRouteEnabled {
            for input in returnStepInputs {
                input.departureDatePicker.date = endDatePicker.date
                input.arrivalDatePicker.date = Calendar.current.date(
                    byAdding: .hour,
                    value: 2,
                    to: endDatePicker.date
                ) ?? endDatePicker.date
            }
        }
        
        if isHotelDetailsEnabled && isHotelDatesEnabled {
            checkOutDatePicker.date = endDatePicker.date
        }
    }
    
    private func makeBasicTripInfoSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Basic Trip Info")
        let card = makeCard()
        
        let destinationBlock = makeDestinationBlock()
        destinationContainerView = destinationBlock
        card.addArrangedSubview(destinationBlock)
        
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
        
        sectionStack.addArrangedSubview(card)
        
        noteSectionStackView.axis = .vertical
        noteSectionStackView.spacing = 12
        updateNoteSection()

        sectionStack.addArrangedSubview(noteSectionStackView)
        
        return sectionStack
    }
    
    private func makeRoutePlanSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Route Plan")
        
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
            routeStepsStackView.axis = .vertical
            routeStepsStackView.spacing = 12
            
            if routeStepInputs.isEmpty {
                addRouteStep()
            }
            
            routeSectionStackView.addArrangedSubview(routeStepsStackView)
            routeSectionStackView.addArrangedSubview(makeRouteActionButton())
        } else {
            routeSectionStackView.addArrangedSubview(
                makeRouteDetailsActionButton(title: "Add route details")
            )
        }
    }
    
    private func makeRouteDetailsActionButton(title: String) -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        routeDetailsActionButton.configuration = configuration
        routeDetailsActionButton.contentHorizontalAlignment = .left
        routeDetailsActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        routeDetailsActionButton.removeTarget(nil, action: nil, for: .allEvents)
        routeDetailsActionButton.addTarget(
            self,
            action: #selector(routeDetailsActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(routeDetailsActionButton)
        routeDetailsActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            routeDetailsActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            routeDetailsActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            routeDetailsActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            routeDetailsActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            routeDetailsActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }

    @objc private func routeDetailsActionButtonTapped() {
        isRouteDetailsEnabled = true
        
        routeStepInputs.removeAll()
        
        routeStepsStackView.arrangedSubviews.forEach { view in
            routeStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        addRouteStep()
        updateRouteSection()
    }
    
    private func addRouteStep() {
        let input = RouteStepInput()
        setupDatePicker(input.departureDatePicker, mode: .dateAndTime)
        setupDatePicker(input.arrivalDatePicker, mode: .dateAndTime)
        
        input.departureDatePicker.date = startDatePicker.date
        input.arrivalDatePicker.date = Calendar.current.date(
            byAdding: .hour,
            value: 2,
            to: startDatePicker.date
        ) ?? startDatePicker.date
        
        if let previousStep = routeStepInputs.last {
            let previousTo = previousStep.toTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if !previousTo.isEmpty {
                input.fromTextField.text = previousTo
            }
        }
        
        routeStepInputs.append(input)
        
        let stepNumber = routeStepInputs.count
        let stepCard = makeRouteStepCard(input: input, stepNumber: stepNumber)
        routeStepsStackView.addArrangedSubview(stepCard)
    }
    
    private func makeRouteStepCard(input: RouteStepInput, stepNumber: Int) -> UIView {
        let card = makeCard()

        if stepNumber == 1 {
            card.addArrangedSubview(
                makeCardHeader(
                    title: isMultiStepRouteEnabled ? "Route Step \(stepNumber)" : "Route Details",
                    action: #selector(removeRouteDetailsTapped)
                )
            )
            card.addArrangedSubview(makeSeparator())
        } else if isMultiStepRouteEnabled {
            card.addArrangedSubview(
                makeRouteStepHeader(
                    stepNumber: stepNumber,
                    inputID: input.id
                )
            )
            card.addArrangedSubview(makeSeparator())
        }
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Transport Type",
                textField: input.transportTypeTextField,
                placeholder: "Plane / Train / Bus / Car"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeTextFieldBlock(
                    title: "From",
                    textField: input.fromTextField,
                    placeholder: "Belgrade"
                ),
                rightView: makeTextFieldBlock(
                    title: "To",
                    textField: input.toTextField,
                    placeholder: "Rome"
                )
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Departure",
                picker: input.departureDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Arrival",
                picker: input.arrivalDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeTextFieldBlock(
                    title: "Company",
                    textField: input.companyTextField,
                    placeholder: "Air Serbia / Trenitalia"
                ),
                rightView: makeTextFieldBlock(
                    title: "Booking No.",
                    textField: input.bookingNumberTextField,
                    placeholder: "JU532 / FR9421"
                )
            )
        )
        
        return card
    }
    
    private func makeRouteStepHeader(stepNumber: Int, inputID: UUID) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = "Route Step \(stepNumber)"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        
        let deleteButton = UIButton(type: .system)
        let trashConfig = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .semibold
        )
        
        deleteButton.setImage(
            UIImage(systemName: "trash", withConfiguration: trashConfig),
            for: .normal
        )
        deleteButton.tintColor = .systemRed
        deleteButton.tag = inputID.hashValue
        
        deleteButton.addTarget(
            self,
            action: #selector(deleteRouteStepTapped(_:)),
            for: .touchUpInside
        )
        
        deleteButton.isHidden = stepNumber == 1
        
        container.addSubview(label)
        container.addSubview(deleteButton)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            label.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            label.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            ),
            
            deleteButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            deleteButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            deleteButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: label.trailingAnchor,
                constant: 12
            ),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return container
    }
    
    private func makeRouteActionButton() -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Create multi-step route"
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        routeActionButton.configuration = configuration
        routeActionButton.contentHorizontalAlignment = .left
        routeActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        routeActionButton.addTarget(
            self,
            action: #selector(routeActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(routeActionButton)
        routeActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            routeActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            routeActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            routeActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            routeActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            routeActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    @objc private func routeActionButtonTapped() {
        if !isMultiStepRouteEnabled {
            isMultiStepRouteEnabled = true
            routeActionButton.configuration?.title = "Add route step"
            
            rebuildRouteSteps()
            addRouteStep()
            return
        }
        
        addRouteStep()
    }
    
    @objc private func deleteRouteStepTapped(_ sender: UIButton) {
        guard let index = routeStepInputs.firstIndex(where: { $0.id.hashValue == sender.tag }) else {
            return
        }
        
        guard index != 0 else {
            return
        }
        
        routeStepInputs.remove(at: index)
        
        if routeStepInputs.count == 1 {
            isMultiStepRouteEnabled = false
            routeActionButton.configuration?.title = "Create multi-step route"
        }
        
        rebuildRouteSteps()
    }
    
    @objc private func removeRouteDetailsTapped() {
        isRouteDetailsEnabled = false
        isMultiStepRouteEnabled = false
        routeStepInputs.removeAll()
        
        routeStepsStackView.arrangedSubviews.forEach { view in
            routeStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        routeActionButton.configuration?.title = "Create multi-step route"
        updateRouteSection()
    }
    
    private func rebuildRouteSteps() {
        routeStepsStackView.arrangedSubviews.forEach { view in
            routeStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for (index, input) in routeStepInputs.enumerated() {
            let card = makeRouteStepCard(
                input: input,
                stepNumber: index + 1
            )
            routeStepsStackView.addArrangedSubview(card)
        }
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
            returnStepsStackView.axis = .vertical
            returnStepsStackView.spacing = 12
            
            if returnStepInputs.isEmpty {
                addReturnStep()
            }
            
            returnRouteSectionStackView.addArrangedSubview(returnStepsStackView)
            returnRouteSectionStackView.addArrangedSubview(makeReturnRouteActionButton())
        } else {
            returnRouteSectionStackView.addArrangedSubview(
                makeReturnRouteDetailsActionButton(title: "Add return route")
            )
        }
    }

    private func makeReturnRouteDetailsActionButton(title: String) -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        returnRouteDetailsActionButton.configuration = configuration
        returnRouteDetailsActionButton.contentHorizontalAlignment = .left
        returnRouteDetailsActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        returnRouteDetailsActionButton.removeTarget(nil, action: nil, for: .allEvents)
        returnRouteDetailsActionButton.addTarget(
            self,
            action: #selector(returnRouteDetailsActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(returnRouteDetailsActionButton)
        returnRouteDetailsActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            returnRouteDetailsActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            returnRouteDetailsActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            returnRouteDetailsActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            returnRouteDetailsActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            returnRouteDetailsActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }

    @objc private func returnRouteDetailsActionButtonTapped() {
        isReturnRouteEnabled = true
        updateReturnRouteSection()
    }
    
    private func addReturnStep() {
        let input = RouteStepInput()
        setupDatePicker(input.departureDatePicker, mode: .dateAndTime)
        setupDatePicker(input.arrivalDatePicker, mode: .dateAndTime)
        
        input.departureDatePicker.date = endDatePicker.date
        input.arrivalDatePicker.date = Calendar.current.date(
            byAdding: .hour,
            value: 2,
            to: endDatePicker.date
        ) ?? endDatePicker.date
        
        if let previousStep = returnStepInputs.last {
            let previousTo = previousStep.toTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if !previousTo.isEmpty {
                input.fromTextField.text = previousTo
            }
        }
        
        returnStepInputs.append(input)
        
        let stepNumber = returnStepInputs.count
        let stepCard = makeReturnStepCard(input: input, stepNumber: stepNumber)
        returnStepsStackView.addArrangedSubview(stepCard)
    }

    private func makeReturnStepCard(input: RouteStepInput, stepNumber: Int) -> UIView {
        let card = makeCard()
        
        if stepNumber == 1 {
            card.addArrangedSubview(
                makeCardHeader(
                    title: isMultiStepReturnRouteEnabled ? "Return Step \(stepNumber)" : "Return Route",
                    action: #selector(removeReturnRouteTapped)
                )
            )
            card.addArrangedSubview(makeSeparator())
        } else if isMultiStepReturnRouteEnabled {
            card.addArrangedSubview(
                makeReturnStepHeader(
                    stepNumber: stepNumber,
                    inputID: input.id
                )
            )
            card.addArrangedSubview(makeSeparator())
        }
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Transport Type",
                textField: input.transportTypeTextField,
                placeholder: "Plane / Train / Bus / Car"
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeTextFieldBlock(
                    title: "From",
                    textField: input.fromTextField,
                    placeholder: "Rome"
                ),
                rightView: makeTextFieldBlock(
                    title: "To",
                    textField: input.toTextField,
                    placeholder: "Belgrade"
                )
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Departure",
                picker: input.departureDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeDateBlock(
                title: "Arrival",
                picker: input.arrivalDatePicker
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        
        card.addArrangedSubview(
            makeTwoColumnRow(
                leftView: makeTextFieldBlock(
                    title: "Company",
                    textField: input.companyTextField,
                    placeholder: "Air Serbia / Trenitalia"
                ),
                rightView: makeTextFieldBlock(
                    title: "Booking No.",
                    textField: input.bookingNumberTextField,
                    placeholder: "JU533 / FR9422"
                )
            )
        )
        
        return card
    }
    
    private func makeReturnStepHeader(stepNumber: Int, inputID: UUID) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = "Return Step \(stepNumber)"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        
        let deleteButton = UIButton(type: .system)
        let trashConfig = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .semibold
        )
        
        deleteButton.setImage(
            UIImage(systemName: "trash", withConfiguration: trashConfig),
            for: .normal
        )
        deleteButton.tintColor = .systemRed
        deleteButton.tag = inputID.hashValue
        
        deleteButton.addTarget(
            self,
            action: #selector(deleteReturnStepTapped(_:)),
            for: .touchUpInside
        )
        
        deleteButton.isHidden = stepNumber == 1
        
        container.addSubview(label)
        container.addSubview(deleteButton)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Layout.fieldVerticalPadding
            ),
            label.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Layout.fieldHorizontalPadding
            ),
            label.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            ),
            
            deleteButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            deleteButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Layout.fieldHorizontalPadding
            ),
            deleteButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: label.trailingAnchor,
                constant: 12
            ),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return container
    }

    private func makeReturnRouteActionButton() -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Create multi-step return route"
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        returnRouteActionButton.configuration = configuration
        returnRouteActionButton.contentHorizontalAlignment = .left
        returnRouteActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        returnRouteActionButton.removeTarget(nil, action: nil, for: .allEvents)
        returnRouteActionButton.addTarget(
            self,
            action: #selector(returnRouteActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(returnRouteActionButton)
        returnRouteActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            returnRouteActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            returnRouteActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            returnRouteActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            returnRouteActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            returnRouteActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }

    @objc private func returnRouteActionButtonTapped() {
        if !isMultiStepReturnRouteEnabled {
            isMultiStepReturnRouteEnabled = true
            returnRouteActionButton.configuration?.title = "Add return step"
            
            rebuildReturnSteps()
            addReturnStep()
            return
        }
        
        addReturnStep()
    }

    @objc private func deleteReturnStepTapped(_ sender: UIButton) {
        guard let index = returnStepInputs.firstIndex(where: { $0.id.hashValue == sender.tag }) else {
            return
        }
        
        guard index != 0 else {
            return
        }
        
        returnStepInputs.remove(at: index)
        
        if returnStepInputs.count == 1 {
            isMultiStepReturnRouteEnabled = false
            returnRouteActionButton.configuration?.title = "Create multi-step return route"
        }
        
        rebuildReturnSteps()
    }

    @objc private func removeReturnRouteTapped() {
        isReturnRouteEnabled = false
        isMultiStepReturnRouteEnabled = false
        returnStepInputs.removeAll()
        
        returnStepsStackView.arrangedSubviews.forEach { view in
            returnStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        returnRouteActionButton.configuration?.title = "Create multi-step return route"
        updateReturnRouteSection()
    }

    private func rebuildReturnSteps() {
        returnStepsStackView.arrangedSubviews.forEach { view in
            returnStepsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for (index, input) in returnStepInputs.enumerated() {
            let card = makeReturnStepCard(
                input: input,
                stepNumber: index + 1
            )
            returnStepsStackView.addArrangedSubview(card)
        }
    }
    
    private func makeHotelDetailsSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Hotel Details")
        
        hotelSectionStackView.axis = .vertical
        hotelSectionStackView.spacing = 12
        
        updateHotelSection()
        
        sectionStack.addArrangedSubview(hotelSectionStackView)
        
        return sectionStack
    }
    
    private func updateHotelSection() {
        hotelSectionStackView.arrangedSubviews.forEach { view in
            hotelSectionStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if isHotelDetailsEnabled {
            hotelSectionStackView.addArrangedSubview(makeHotelInfoCard())
            
            if isHotelDatesEnabled {
                hotelSectionStackView.addArrangedSubview(makeHotelDatesCard())
            } else {
                hotelSectionStackView.addArrangedSubview(
                    makeHotelDatesActionButton(title: "Add check-in / check-out")
                )
            }
        } else {
            hotelSectionStackView.addArrangedSubview(
                makeHotelActionButton(title: "Add hotel details")
            )
        }
    }
    
    private func makeHotelInfoCard() -> UIView {
        let card = makeCard()
        
        card.addArrangedSubview(makeCardHeader(title: "Hotel Info", action: #selector(hotelActionButtonTapped)))
        card.addArrangedSubview(makeSeparator())
        
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
        
        return card
    }
    
    private func makeHotelDatesCard() -> UIView {
        let card = makeCard()
        
        card.addArrangedSubview(
            makeCardHeader(
                title: "Check-in / Check-out",
                action: #selector(hotelDatesActionButtonTapped)
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
        
        return card
    }
    
    private func makeCardHeader(title: String, action: Selector) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .label
        
        let deleteButton = UIButton(type: .system)
        let trashConfig = UIImage.SymbolConfiguration(
            pointSize: 14,
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
    
    private func makeHotelActionButton(title: String) -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        if isHotelDetailsEnabled {
            let trashConfig = UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .semibold
            )
            
            configuration.image = UIImage(
                systemName: "trash",
                withConfiguration: trashConfig
            )
            configuration.baseForegroundColor = .systemRed
        } else {
            configuration.image = UIImage(systemName: "plus.circle.fill")
            configuration.baseForegroundColor = .systemBlue
        }
        
        hotelActionButton.configuration = configuration
        hotelActionButton.contentHorizontalAlignment = .left
        hotelActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        hotelActionButton.removeTarget(nil, action: nil, for: .allEvents)
        hotelActionButton.addTarget(
            self,
            action: #selector(hotelActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(hotelActionButton)
        hotelActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hotelActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            hotelActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hotelActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hotelActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            hotelActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    private func makeHotelDatesActionButton(title: String) -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        if isHotelDatesEnabled {
            let trashConfig = UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .semibold
            )
            
            configuration.image = UIImage(
                systemName: "trash",
                withConfiguration: trashConfig
            )
            configuration.baseForegroundColor = .systemRed
        } else {
            configuration.image = UIImage(systemName: "plus.circle.fill")
            configuration.baseForegroundColor = .systemBlue
        }
        
        hotelDatesActionButton.configuration = configuration
        hotelDatesActionButton.contentHorizontalAlignment = .left
        hotelDatesActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        hotelDatesActionButton.removeTarget(nil, action: nil, for: .allEvents)
        hotelDatesActionButton.addTarget(
            self,
            action: #selector(hotelDatesActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(hotelDatesActionButton)
        hotelDatesActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hotelDatesActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            hotelDatesActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hotelDatesActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hotelDatesActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            hotelDatesActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    @objc private func hotelActionButtonTapped() {
        if isHotelDetailsEnabled {
            isHotelDetailsEnabled = false
            isHotelDatesEnabled = false
            hotelNameTextField.text = ""
            addressTextField.text = ""
        } else {
            isHotelDetailsEnabled = true
        }
        
        updateHotelSection()
    }
    
    @objc private func hotelDatesActionButtonTapped() {
        isHotelDatesEnabled.toggle()
        updateHotelSection()
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
        
        card.backgroundColor = .cardBackground
        card.layer.cornerRadius = Layout.cardCornerRadius
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        
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
    
    private func makeDestinationBlock() -> UIView {
        let container = UIView()
        let titleLabel = makeFieldTitleLabel("Destination *")
        
        destinationTextField.placeholder = "Final destination"
        destinationTextField.borderStyle = .none
        destinationTextField.backgroundColor = .clear
        destinationTextField.font = .systemFont(
            ofSize: Layout.inputFontSize,
            weight: .medium
        )
        destinationTextField.textColor = .label
        destinationTextField.autocapitalizationType = .words
        
        destinationTextField.addTarget(
            self,
            action: #selector(destinationTextChanged),
            for: .editingChanged
        )
        
        destinationErrorLabel.text = "Please enter destination."
        destinationErrorLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        destinationErrorLabel.textColor = .systemRed
        destinationErrorLabel.isHidden = true
        
        container.addSubview(titleLabel)
        container.addSubview(destinationTextField)
        container.addSubview(destinationErrorLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        destinationErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            destinationTextField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 4
            ),
            destinationTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            destinationTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            destinationErrorLabel.topAnchor.constraint(
                equalTo: destinationTextField.bottomAnchor,
                constant: 6
            ),
            destinationErrorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            destinationErrorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            destinationErrorLabel.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -Layout.fieldVerticalPadding
            )
        ])
        
        return container
    }
    
    @objc private func destinationTextChanged() {
        hideDestinationError()
        updateSaveButtonState()
    }

    private func updateSaveButtonState() {
        let destination = destinationTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let isValid = !destination.isEmpty
        
        saveButton.isEnabled = true
        saveButton.backgroundColor = isValid ? .systemBlue : .systemGray4
        saveButton.layer.shadowOpacity = isValid ? 0.20 : 0
    }

    private func showDestinationError() {
        destinationErrorLabel.isHidden = false
        destinationTextField.textColor = .systemRed
    }

    private func hideDestinationError() {
        destinationErrorLabel.isHidden = true
        destinationTextField.textColor = .label
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
    
    private func updateNoteSection() {
        noteSectionStackView.arrangedSubviews.forEach { view in
            noteSectionStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if isNoteEnabled {
            noteSectionStackView.addArrangedSubview(makeNoteCard())
        } else {
            noteSectionStackView.addArrangedSubview(makeNoteActionButton(title: "Add note"))
        }
    }

    private func makeNoteCard() -> UIView {
        let card = makeCard()
        
        card.addArrangedSubview(
            makeCardHeader(
                title: "Notes",
                action: #selector(noteActionButtonTapped)
            )
        )
        
        card.addArrangedSubview(makeSeparator())
        card.addArrangedSubview(makeNoteBlock())
        
        return card
    }

    private func makeNoteActionButton(title: String) -> UIView {
        let container = UIView()
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        noteActionButton.configuration = configuration
        noteActionButton.contentHorizontalAlignment = .left
        noteActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        noteActionButton.removeTarget(nil, action: nil, for: .allEvents)
        noteActionButton.addTarget(
            self,
            action: #selector(noteActionButtonTapped),
            for: .touchUpInside
        )
        
        container.addSubview(noteActionButton)
        noteActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noteActionButton.topAnchor.constraint(equalTo: container.topAnchor),
            noteActionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            noteActionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            noteActionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            noteActionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }

    @objc private func noteActionButtonTapped() {
        isNoteEnabled.toggle()
        
        if !isNoteEnabled {
            noteTextView.text = notePlaceholder
            noteTextView.textColor = .placeholderText
        }
        
        updateNoteSection()
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
        let typedDestination = destinationTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !typedDestination.isEmpty else {
            showDestinationError()
            updateSaveButtonState()
            return
        }
        
        let destination = destinationTextField.text ?? ""
        
        let routeStartDate = isRouteDetailsEnabled
        ? routeStepInputs.first?.departureDatePicker.date
        : nil

        let routeEndDate = isRouteDetailsEnabled
        ? routeStepInputs.last?.arrivalDatePicker.date
        : nil

        let startDate = didChangeStartDate
        ? startDatePicker.date
        : routeStartDate ?? startDatePicker.date

        let endDate = didChangeEndDate
        ? endDatePicker.date
        : routeEndDate ?? endDatePicker.date
        
        let note = isNoteEnabled && noteTextView.textColor != .placeholderText
        ? noteTextView.text ?? ""
        : ""
        
        let routeSteps: [TransportSegment] = isRouteDetailsEnabled
        ? routeStepInputs.map { input in
            TransportSegment(
                id: UUID(),
                transportType: input.transportTypeTextField.text ?? "",
                from: input.fromTextField.text ?? "",
                to: input.toTextField.text ?? "",
                departureDate: input.departureDatePicker.date,
                arrivalDate: input.arrivalDatePicker.date,
                company: input.companyTextField.text ?? "",
                bookingNumber: input.bookingNumberTextField.text ?? ""
            )
        }
        : []
        
        let firstRouteStep = routeSteps.first
        
        let transportType = firstRouteStep?.transportType ?? ""
        let from = firstRouteStep?.from ?? ""
        let to = firstRouteStep?.to ?? ""
        let departureDate = firstRouteStep?.departureDate ?? Date()
        let arrivalDate = firstRouteStep?.arrivalDate ?? Date()
        let company = firstRouteStep?.company ?? ""
        let bookingNumber = firstRouteStep?.bookingNumber ?? ""
        
        let hotelName = isHotelDetailsEnabled ? hotelNameTextField.text ?? "" : ""
        let address = isHotelDetailsEnabled ? addressTextField.text ?? "" : ""
        let checkInDate = isHotelDatesEnabled ? checkInDatePicker.date : Date()
        let checkOutDate = isHotelDatesEnabled ? checkOutDatePicker.date : Date()
        
        let returnRouteSteps: [TransportSegment] = isReturnRouteEnabled
        ? returnStepInputs.map { input in
            TransportSegment(
                id: UUID(),
                transportType: input.transportTypeTextField.text ?? "",
                from: input.fromTextField.text ?? "",
                to: input.toTextField.text ?? "",
                departureDate: input.departureDatePicker.date,
                arrivalDate: input.arrivalDatePicker.date,
                company: input.companyTextField.text ?? "",
                bookingNumber: input.bookingNumberTextField.text ?? ""
            )
        }
        : []
        
        let result = viewModel.makeTrip(
            tripID: editingTrip?.id ?? UUID(),
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
            routeSteps: routeSteps,
            hasReturnTicket: isReturnRouteEnabled,
            returnRouteSteps: returnRouteSteps,
            checklistItems: editingTrip?.checklistItems ?? [],
            hasHotelDates: isHotelDatesEnabled,
            hasHotelDetails: isHotelDetailsEnabled,
            hotelName: hotelName,
            address: address,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate
        )
        
        switch result {
        case .success(let trip):
            if editingTrip == nil {
                onTripCreated?(trip)
            } else {
                onTripUpdated?(trip)
            }
            
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
