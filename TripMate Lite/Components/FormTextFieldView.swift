//
//  FormTextFieldView.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class FormTextFieldView: UIView {
    
    private enum Layout {
        static let labelFontSize: CGFloat = 16
        static let inputHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 12
        static let leftPadding: CGFloat = 16
        static let spacing: CGFloat = 8
    }
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let stackView = UIStackView()
    
    var text: String {
        textField.text ?? ""
    }
    
    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        
        setupUI(title: title, placeholder: placeholder)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, placeholder: String) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.labelFontSize)
        titleLabel.textColor = .label
        
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .cardBackground
        textField.autocapitalizationType = .words
        
        textField.layer.cornerRadius = Layout.cornerRadius
        textField.clipsToBounds = true
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: Layout.leftPadding,
                height: Layout.inputHeight
            )
        )
        
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: Layout.inputHeight)
        ])
    }
}
