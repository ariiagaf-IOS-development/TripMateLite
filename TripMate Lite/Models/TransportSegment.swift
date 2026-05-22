//
//  TransportSegment.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 23.05.2026.
//

import Foundation

struct TransportSegment {
    let id: UUID
    let transportType: String
    let from: String
    let to: String
    let departureDate: Date
    let arrivalDate: Date
    let company: String
    let bookingNumber: String
}
