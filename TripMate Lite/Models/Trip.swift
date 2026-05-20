//
//  Trip.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 14.05.2026.
//

import Foundation

struct Trip {
    let id: UUID
    let basicInfo: BasicTripInfo
    let transportDetails: TransportDetails
    let hotelDetails: HotelDetails
}
