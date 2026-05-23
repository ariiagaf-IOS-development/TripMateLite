//
//  AddTripViewController.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 14.05.2026.
//

import UIKit

final class AddTripViewController: UIViewController {
    
    var onTripCreated: ((Trip) -> Void)?
    
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
    private let noteTextView = UITextView()
    
    private var isNoteEnabled = false
    private let noteSectionStackView = UIStackView()
    private let noteActionButton = UIButton(type: .system)
    
    private var routeStepInputs: [RouteStepInput] = []
    private let routeStepsStackView = UIStackView()
    private let routeActionButton = UIButton(type: .system)
    private var isMultiStepRouteEnabled = false
    
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
        stackView.addArrangedSubview(makeHotelDetailsSection())
    }
    
    @objc private func startDateChanged() {
        didChangeStartDate = true
    }

    @objc private func endDateChanged() {
        didChangeEndDate = true
    }
    
    private func makeBasicTripInfoSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Basic Trip Info")
        let card = makeCard()
        
        card.addArrangedSubview(
            makeTextFieldBlock(
                title: "Destination *",
                textField: destinationTextField,
                placeholder: "e.g. Rome"
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
        
        sectionStack.addArrangedSubview(card)
        
        noteSectionStackView.axis = .vertical
        noteSectionStackView.spacing = 12
        updateNoteSection()

        sectionStack.addArrangedSubview(noteSectionStackView)
        
        return sectionStack
    }
    
    private func makeRoutePlanSection() -> UIView {
        let sectionStack = makeSectionStack(title: "Route Plan")
        
        routeStepsStackView.axis = .vertical
        routeStepsStackView.spacing = 12
        
        addRouteStep()
        
        sectionStack.addArrangedSubview(routeStepsStackView)
        sectionStack.addArrangedSubview(makeRouteActionButton())
        
        return sectionStack
    }
    
    private func addRouteStep() {
        let input = RouteStepInput()
        setupDatePicker(input.departureDatePicker, mode: .dateAndTime)
        setupDatePicker(input.arrivalDatePicker, mode: .dateAndTime)
        
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
        
        if isMultiStepRouteEnabled {
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
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
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
        let typedDestination = destinationTextField.text ?? ""

        let lastRouteDestination = routeStepInputs.last?.toTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let destination = typedDestination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? lastRouteDestination
        : typedDestination
        
        let routeStartDate = routeStepInputs.first?.departureDatePicker.date
        let routeEndDate = routeStepInputs.last?.arrivalDatePicker.date

        let startDate = didChangeStartDate
        ? startDatePicker.date
        : routeStartDate ?? startDatePicker.date

        let endDate = didChangeEndDate
        ? endDatePicker.date
        : routeEndDate ?? endDatePicker.date
        
        let note = isNoteEnabled && noteTextView.textColor != .placeholderText
        ? noteTextView.text ?? ""
        : ""
        
        let routeSteps = routeStepInputs.map { input in
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
            routeSteps: routeSteps,
            hasHotelDates: isHotelDatesEnabled,
            hasHotelDetails: isHotelDetailsEnabled,
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
