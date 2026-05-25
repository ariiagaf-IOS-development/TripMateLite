//
//  AddTripViewModel.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 15.05.2026.
//

import Foundation

final class AddTripViewModel {
    
    enum Result {
        case success(Trip)
        case failure(String)
    }
    
    func makeTrip(
        tripID: UUID,
        folderID: UUID?,
        destination: String,
        startDate: Date,
        endDate: Date,
        note: String,
        transportType: String,
        from: String,
        to: String,
        departureDate: Date,
        arrivalDate: Date,
        company: String,
        bookingNumber: String,
        routeSteps: [TransportSegment],
        hasReturnTicket: Bool,
        returnRouteSteps: [TransportSegment],
        checklistItems: [ChecklistItem],
        activities: [TripActivity],
        hasHotelDates: Bool,
        hasHotelDetails: Bool,
        hotelName: String,
        address: String,
        checkInDate: Date,
        checkOutDate: Date
    ) -> Result {
        
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedDestination.isEmpty {
            return .failure("Please enter destination.")
        }
        
        if endDate < startDate {
            return .failure("End date must be after start date.")
        }
        
        if arrivalDate < departureDate {
            return .failure("Arrival date must be after departure date.")
        }
        
        if hasHotelDates && checkOutDate < checkInDate {
            return .failure("Check-out date must be after check-in date.")
        }
        
        for step in routeSteps {
            if step.arrivalDate < step.departureDate {
                return .failure("Arrival date must be after departure date in all route steps.")
            }
        }
        
        let basicInfo = BasicTripInfo(
            destination: trimmedDestination,
            startDate: startDate,
            endDate: endDate,
            note: note
        )
        
        let transportDetails = TransportDetails(
            transportType: transportType,
            from: from,
            to: to,
            departureDate: departureDate,
            arrivalDate: arrivalDate,
            company: company,
            bookingNumber: bookingNumber
        )
        
        let hotelDetails = HotelDetails(
            hotelName: hotelName,
            address: address,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate
        )
        
        let trip = Trip(
            id: tripID,
            folderID: folderID,
            basicInfo: basicInfo,
            transportDetails: transportDetails,
            routeSteps: routeSteps,
            hotelDetails: hotelDetails,
            hasHotelDetails: hasHotelDetails,
            hasHotelDates: hasHotelDates,
            checklistItems: checklistItems,
            hasReturnTicket: hasReturnTicket,
            returnRouteSteps: returnRouteSteps,
            activities: activities
        )
        
        return .success(trip)
    }
}
