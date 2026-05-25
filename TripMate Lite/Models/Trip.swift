//
//  Trip.swift
//  TripMate Lite
//

import Foundation

struct Trip {
    let id: UUID
    let folderID: UUID?
    
    let basicInfo: BasicTripInfo
    
    let transportDetails: TransportDetails
    let routeSteps: [TransportSegment]
    
    let hotelDetails: HotelDetails
    let hasHotelDetails: Bool
    let hasHotelDates: Bool
    
    let checklistItems: [ChecklistItem]
    
    let hasReturnTicket: Bool
    let returnRouteSteps: [TransportSegment]
    
    let activities: [TripActivity]
    
    init(
        id: UUID,
        folderID: UUID? = nil,
        basicInfo: BasicTripInfo,
        transportDetails: TransportDetails,
        routeSteps: [TransportSegment] = [],
        hotelDetails: HotelDetails,
        hasHotelDetails: Bool = false,
        hasHotelDates: Bool = false,
        checklistItems: [ChecklistItem] = [],
        hasReturnTicket: Bool = false,
        returnRouteSteps: [TransportSegment] = [],
        activities: [TripActivity] = []
    ) {
        self.id = id
        self.folderID = folderID
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
        self.checklistItems = checklistItems
        self.hasReturnTicket = hasReturnTicket
        self.returnRouteSteps = returnRouteSteps
        self.activities = activities
    }
}
