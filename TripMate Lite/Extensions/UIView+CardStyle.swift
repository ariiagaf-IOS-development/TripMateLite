//
//  UIView+CardStyle.swift
//  TripMate Lite
//

import UIKit

extension UIView {
    
    func applyCardStyle() {
        backgroundColor = UIColor.cardBackground
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        clipsToBounds = false
    }
}
