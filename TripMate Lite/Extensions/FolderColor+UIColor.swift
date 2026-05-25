//
//  FolderColor+UIColor.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import UIKit

extension String {
    
    var folderUIColor: UIColor {
        switch self {
        case "purple":
            return .systemPurple
        case "orange":
            return .systemOrange
        case "green":
            return .systemGreen
        case "pink":
            return .systemPink
        case "gray":
            return .systemGray
        default:
            return .systemBlue
        }
    }
}
