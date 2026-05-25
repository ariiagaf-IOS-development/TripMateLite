//
//  Date+Formatting.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 19.05.2026.
//

import Foundation

extension Date {
    
    var tripDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: self)
    }
    
    var tripDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: self)
    }
    
    var tripTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
