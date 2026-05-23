//
//  TransportDetails+Display.swift
//  TripMate Lite
//

import Foundation

extension TransportDetails {
    
    var displayType: String {
        let type = transportType.trimmingCharacters(in: .whitespacesAndNewlines)
        return type.isEmpty ? "Transport" : type
    }
    
    var iconName: String {
        let type = transportType.lowercased()
        
        if type.contains("plane") || type.contains("flight") || type.contains("air") {
            return "airplane"
        } else if type.contains("train") {
            return "train.side.front.car"
        } else if type.contains("bus") {
            return "bus.fill"
        } else if type.contains("car") || type.contains("taxi") {
            return "car.fill"
        } else if type.contains("ferry") || type.contains("boat") {
            return "ferry.fill"
        } else if type.contains("walk") {
            return "figure.walk"
        } else {
            return "arrow.triangle.branch"
        }
    }
}
