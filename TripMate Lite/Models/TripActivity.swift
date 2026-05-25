//
//  TripActivity.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 25.05.2026.
//

import Foundation

struct TripActivity {
    let id: UUID
    var title: String
    var date: Date
    var hasTime: Bool
    var time: Date
    var location: String
    var note: String
    var bookingNumber: String
    var isBooked: Bool
    
    var hasRouteDetails: Bool
    var routeDetails: TransportSegment
    
    let hasReturnRoute: Bool
    let returnRouteDetails: TransportSegment
}
