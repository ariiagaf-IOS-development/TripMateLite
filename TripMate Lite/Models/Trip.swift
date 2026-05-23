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
    let routeSteps: [TransportSegment]
    let hotelDetails: HotelDetails
    
    let hasHotelDetails: Bool
    let hasHotelDates: Bool
    
    init(
        id: UUID,
        basicInfo: BasicTripInfo,
        transportDetails: TransportDetails,
        routeSteps: [TransportSegment] = [],
        hotelDetails: HotelDetails,
        hasHotelDetails: Bool = false,
        hasHotelDates: Bool = false
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
        self.hasHotelDetails = hasHotelDetails
        self.hasHotelDates = hasHotelDates
    }
}
