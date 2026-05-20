//
//  SectionHeaderView.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import UIKit

final class SectionHeaderView: UIView {
    
    private enum Layout {
        static let titleFontSize: CGFloat = 24
        static let emojiFontSize: CGFloat = 24
        static let height: CGFloat = 32
    }
    
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    
    init(title: String, emoji: String) {
        super.init(frame: .zero)
        
        setupUI(title: title, emoji: emoji)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, emoji: String) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: Layout.emojiFontSize)
        
        addSubview(titleLabel)
        addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(equalToConstant: Layout.height)
        ])
    }
}
