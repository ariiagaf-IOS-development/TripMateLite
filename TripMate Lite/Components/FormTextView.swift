//
//  FormTextView.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class FormTextView: UIView {
    
    private enum Layout {
        static let labelFontSize: CGFloat = 16
        static let textViewFontSize: CGFloat = 16
        static let textViewHeight: CGFloat = 96
        static let cornerRadius: CGFloat = 12
        static let spacing: CGFloat = 8
        
        static let textInsetTop: CGFloat = 12
        static let textInsetLeft: CGFloat = 12
        static let textInsetBottom: CGFloat = 12
        static let textInsetRight: CGFloat = 12
    }
    
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let stackView = UIStackView()
    
    private let placeholder: String
    
    var text: String {
        textView.textColor == .placeholderText ? "" : textView.text
    }
    
    init(title: String, placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        
        setupUI(title: title)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.labelFontSize)
        titleLabel.textColor = .label
        
        textView.text = placeholder
        textView.textColor = .placeholderText
        textView.delegate = self
        
        textView.font = .systemFont(ofSize: Layout.textViewFontSize)
        textView.backgroundColor = .cardBackground
        textView.layer.cornerRadius = Layout.cornerRadius
        textView.clipsToBounds = true
        textView.textContainerInset = UIEdgeInsets(
            top: Layout.textInsetTop,
            left: Layout.textInsetLeft,
            bottom: Layout.textInsetBottom,
            right: Layout.textInsetRight
        )
        
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textView)
        
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textView.heightAnchor.constraint(equalToConstant: Layout.textViewHeight)
        ])
    }
}

extension FormTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText
        }
    }
}
