//
//  TripStorage.swift
//  TripMate Lite
//
//  Created by Арина Агафонова on 20.05.2026.
//

import UIKit
import CoreData

final class TripStorage {
    static let shared = TripStorage()
    
    private init() {}
    
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get AppDelegate")
        }
        
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveTrip(_ trip: Trip) {
        let entity = TripEntity(context: context)
        
        entity.id = trip.id
        
        entity.destination = trip.basicInfo.destination
        entity.startDate = trip.basicInfo.startDate
        entity.endDate = trip.basicInfo.endDate
        entity.note = trip.basicInfo.note
        
        entity.transportType = trip.transportDetails.transportType
        entity.from = trip.transportDetails.from
        entity.to = trip.transportDetails.to
        entity.departureDate = trip.transportDetails.departureDate
        entity.arrivalDate = trip.transportDetails.arrivalDate
        entity.company = trip.transportDetails.company
        entity.bookingNumber = trip.transportDetails.bookingNumber
        
        entity.hotelName = trip.hotelDetails.hotelName
        entity.address = trip.hotelDetails.address
        entity.checkInDate = trip.hotelDetails.checkInDate
        entity.checkOutDate = trip.hotelDetails.checkOutDate
        
        entity.hasHotelDetails = trip.hasHotelDetails
        entity.hasHotelDates = trip.hasHotelDates
        
        entity.hasReturnTicket = trip.hasReturnTicket
        
        saveRouteSteps(trip.routeSteps, for: entity)
        saveReturnRouteSteps(trip.returnRouteSteps, for: entity)
        
        saveChecklistItems(trip.checklistItems, for: entity)
        
        saveContext()
    }
    
    func updateTrip(_ trip: Trip) {
        let request: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id == %@",
            trip.id as CVarArg
        )
        
        do {
            let entities = try context.fetch(request)
            
            guard let entity = entities.first else {
                return
            }
            
            entity.destination = trip.basicInfo.destination
            entity.startDate = trip.basicInfo.startDate
            entity.endDate = trip.basicInfo.endDate
            entity.note = trip.basicInfo.note
            
            entity.transportType = trip.transportDetails.transportType
            entity.from = trip.transportDetails.from
            entity.to = trip.transportDetails.to
            entity.departureDate = trip.transportDetails.departureDate
            entity.arrivalDate = trip.transportDetails.arrivalDate
            entity.company = trip.transportDetails.company
            entity.bookingNumber = trip.transportDetails.bookingNumber
            
            entity.hotelName = trip.hotelDetails.hotelName
            entity.address = trip.hotelDetails.address
            entity.checkInDate = trip.hotelDetails.checkInDate
            entity.checkOutDate = trip.hotelDetails.checkOutDate
            
            entity.hasHotelDetails = trip.hasHotelDetails
            entity.hasHotelDates = trip.hasHotelDates
            
            entity.hasReturnTicket = trip.hasReturnTicket

            deleteOldRouteSteps(for: entity)
            saveRouteSteps(trip.routeSteps, for: entity)

            deleteOldReturnRouteSteps(for: entity)
            saveReturnRouteSteps(trip.returnRouteSteps, for: entity)

            deleteOldChecklistItems(for: entity)
            saveChecklistItems(trip.checklistItems, for: entity)
            
            saveContext()
        } catch {
            print("Failed to update trip:", error)
        }
    }
    
    func fetchTrips() -> [Trip] {
        let request: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "startDate", ascending: true)
        ]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { makeTrip(from: $0) }
        } catch {
            print("Failed to fetch trips:", error)
            return []
        }
    }
    
    func deleteTrip(_ trip: Trip) {
        let request: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id == %@",
            trip.id as CVarArg
        )
        
        do {
            let entities = try context.fetch(request)
            
            if let entityToDelete = entities.first {
                context.delete(entityToDelete)
                saveContext()
            }
        } catch {
            print("Failed to delete trip:", error)
        }
    }
    
    private func saveRouteSteps(
        _ routeSteps: [TransportSegment],
        for tripEntity: TripEntity
    ) {
        for (index, step) in routeSteps.enumerated() {
            let segmentEntity = TransportSegmentEntity(context: context)
            
            segmentEntity.id = step.id
            segmentEntity.transportType = step.transportType
            segmentEntity.from = step.from
            segmentEntity.to = step.to
            segmentEntity.departureDate = step.departureDate
            segmentEntity.arrivalDate = step.arrivalDate
            segmentEntity.company = step.company
            segmentEntity.bookingNumber = step.bookingNumber
            segmentEntity.orderIndex = Int16(index)
            
            segmentEntity.trip = tripEntity
        }
    }
    
    private func saveReturnRouteSteps(
        _ returnRouteSteps: [TransportSegment],
        for tripEntity: TripEntity
    ) {
        for (index, step) in returnRouteSteps.enumerated() {
            let segmentEntity = ReturnSegmentEntity(context: context)
            
            segmentEntity.id = step.id
            segmentEntity.transportType = step.transportType
            segmentEntity.from = step.from
            segmentEntity.to = step.to
            segmentEntity.departureDate = step.departureDate
            segmentEntity.arrivalDate = step.arrivalDate
            segmentEntity.company = step.company
            segmentEntity.bookingNumber = step.bookingNumber
            segmentEntity.orderIndex = Int16(index)
            
            segmentEntity.trip = tripEntity
        }
    }

    private func deleteOldReturnRouteSteps(for tripEntity: TripEntity) {
        guard let oldSegments = tripEntity.returnSegments as? Set<ReturnSegmentEntity> else {
            return
        }
        
        for segment in oldSegments {
            context.delete(segment)
        }
    }
    
    private func saveChecklistItems(
        _ items: [ChecklistItem],
        for tripEntity: TripEntity
    ) {
        for item in items {
            let entity = ChecklistItemEntity(context: context)
            
            entity.id = item.id
            entity.title = item.title
            entity.isCompleted = item.isCompleted
            entity.trip = tripEntity
        }
    }

    private func deleteOldChecklistItems(for tripEntity: TripEntity) {
        guard let oldItems = tripEntity.checklistItems as? Set<ChecklistItemEntity> else {
            return
        }
        
        for item in oldItems {
            context.delete(item)
        }
    }
    
    private func deleteOldRouteSteps(for tripEntity: TripEntity) {
        guard let oldSegments = tripEntity.routeSegments as? Set<TransportSegmentEntity> else {
            return
        }
        
        for segment in oldSegments {
            context.delete(segment)
        }
    }
    
    private func makeTrip(from entity: TripEntity) -> Trip {
        let basicInfo = BasicTripInfo(
            destination: entity.destination ?? "",
            startDate: entity.startDate ?? Date(),
            endDate: entity.endDate ?? Date(),
            note: entity.note ?? ""
        )
        
        let transportDetails = TransportDetails(
            transportType: entity.transportType ?? "",
            from: entity.from ?? "",
            to: entity.to ?? "",
            departureDate: entity.departureDate ?? Date(),
            arrivalDate: entity.arrivalDate ?? Date(),
            company: entity.company ?? "",
            bookingNumber: entity.bookingNumber ?? ""
        )
        
        let routeSteps = makeRouteSteps(from: entity)
        
        let returnRouteSteps = makeReturnRouteSteps(from: entity)
        
        let hotelDetails = HotelDetails(
            hotelName: entity.hotelName ?? "",
            address: entity.address ?? "",
            checkInDate: entity.checkInDate ?? Date(),
            checkOutDate: entity.checkOutDate ?? Date()
        )
        
        let checklistItems = (entity.checklistItems as? Set<ChecklistItemEntity> ?? [])
            .map {
                ChecklistItem(
                    id: $0.id ?? UUID(),
                    title: $0.title ?? "",
                    isCompleted: $0.isCompleted
                )
            }
            .sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        
        return Trip(
            id: entity.id ?? UUID(),
            basicInfo: basicInfo,
            transportDetails: transportDetails,
            routeSteps: routeSteps,
            hotelDetails: hotelDetails,
            hasHotelDetails: entity.hasHotelDetails,
            hasHotelDates: entity.hasHotelDates,
            checklistItems: checklistItems,
            hasReturnTicket: entity.hasReturnTicket,
            returnRouteSteps: returnRouteSteps
        )
    }
    
    private func makeRouteSteps(from entity: TripEntity) -> [TransportSegment] {
        guard let segmentEntities = entity.routeSegments as? Set<TransportSegmentEntity>,
              !segmentEntities.isEmpty else {
            return []
        }
        
        return segmentEntities
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { segmentEntity in
                TransportSegment(
                    id: segmentEntity.id ?? UUID(),
                    transportType: segmentEntity.transportType ?? "",
                    from: segmentEntity.from ?? "",
                    to: segmentEntity.to ?? "",
                    departureDate: segmentEntity.departureDate ?? Date(),
                    arrivalDate: segmentEntity.arrivalDate ?? Date(),
                    company: segmentEntity.company ?? "",
                    bookingNumber: segmentEntity.bookingNumber ?? ""
                )
            }
    }
    
    private func makeReturnRouteSteps(from entity: TripEntity) -> [TransportSegment] {
        guard let segmentEntities = entity.returnSegments as? Set<ReturnSegmentEntity>,
              !segmentEntities.isEmpty else {
            return []
        }
        
        return segmentEntities
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { segmentEntity in
                TransportSegment(
                    id: segmentEntity.id ?? UUID(),
                    transportType: segmentEntity.transportType ?? "",
                    from: segmentEntity.from ?? "",
                    to: segmentEntity.to ?? "",
                    departureDate: segmentEntity.departureDate ?? Date(),
                    arrivalDate: segmentEntity.arrivalDate ?? Date(),
                    company: segmentEntity.company ?? "",
                    bookingNumber: segmentEntity.bookingNumber ?? ""
                )
            }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context:", error)
            }
        }
    }
}
