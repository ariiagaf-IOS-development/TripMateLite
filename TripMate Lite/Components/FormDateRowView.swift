//
//  FormDateRowView.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class FormDateRowView: UIView {
    
    private enum Layout {
        static let labelFontSize: CGFloat = 16
        static let height: CGFloat = 44
        static let labelWidth: CGFloat = 160
    }
    
    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    var date: Date {
        datePicker.date
    }
    
    init(title: String, mode: UIDatePicker.Mode) {
        super.init(frame: .zero)
        
        setupUI(title: title, mode: mode)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, mode: UIDatePicker.Mode) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.labelFontSize)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        datePicker.datePickerMode = mode
        datePicker.preferredDatePickerStyle = .compact
        
        addSubview(titleLabel)
        addSubview(datePicker)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: Layout.labelWidth),
            
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
