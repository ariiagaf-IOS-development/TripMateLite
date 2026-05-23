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
    
    // Old single route field, kept for compatibility
    let transportDetails: TransportDetails
    
    // New multi-step route field
    let routeSteps: [TransportSegment]
    
    let hotelDetails: HotelDetails
    
    init(
        id: UUID,
        basicInfo: BasicTripInfo,
        transportDetails: TransportDetails,
        routeSteps: [TransportSegment] = [],
        hotelDetails: HotelDetails
    ) {
        self.id = id
        self.basicInfo = basicInfo
        self.transportDetails = transportDetails
        
        if routeSteps.isEmpty {
            self.routeSteps = [
                TransportSegment(
                    id: UUID(),
                    transportType: transportDetails.transportType,
                    from: transportDetails.from,
                    to: transportDetails.to,
                    departureDate: transportDetails.departureDate,
                    arrivalDate: transportDetails.arrivalDate,
                    company: transportDetails.company,
                    bookingNumber: transportDetails.bookingNumber
                )
            ]
        } else {
            self.routeSteps = routeSteps
        }
        
        self.hotelDetails = hotelDetails
    }
}
