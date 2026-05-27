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
        
        entity.folderID = trip.folderID
        
        entity.destination = trip.basicInfo.destination
        entity.startDate = trip.basicInfo.startDate
        entity.endDate = trip.basicInfo.endDate
        entity.note = trip.basicInfo.note
        
        entity.transportType = trip.transportDetails.transportType
        entity.from = trip.transportDetails.from
        entity.to = trip.transportDetails.to
        entity.departurePlace = trip.transportDetails.departurePlace
        entity.arrivalPlace = trip.transportDetails.arrivalPlace
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
        saveActivities(trip.activities, for: entity)

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
            
            entity.folderID = trip.folderID
            
            entity.destination = trip.basicInfo.destination
            entity.startDate = trip.basicInfo.startDate
            entity.endDate = trip.basicInfo.endDate
            entity.note = trip.basicInfo.note
            
            entity.transportType = trip.transportDetails.transportType
            entity.from = trip.transportDetails.from
            entity.to = trip.transportDetails.to
            entity.departurePlace = trip.transportDetails.departurePlace
            entity.arrivalPlace = trip.transportDetails.arrivalPlace
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

            deleteOldActivities(for: entity)
            saveActivities(trip.activities, for: entity)

            saveContext()
        } catch {
            print("Failed to update trip:", error)
        }
    }
    
    private func saveActivities(
        _ activities: [TripActivity],
        for tripEntity: TripEntity
    ) {
        for (index, activity) in activities.enumerated() {
            let entity = TripActivityEntity(context: context)
            
            entity.id = activity.id
            entity.title = activity.title
            entity.date = activity.date
            entity.hasTime = activity.hasTime
            entity.time = activity.time
            entity.location = activity.location
            entity.note = activity.note
            entity.bookingNumber = activity.bookingNumber
            entity.isBooked = activity.isBooked
            
            entity.hasRouteDetails = activity.hasRouteDetails
            entity.routeTransportType = activity.routeDetails.transportType
            entity.routeFrom = activity.routeDetails.from
            entity.routeTo = activity.routeDetails.to
            entity.routeDeparturePlace = activity.routeDetails.departurePlace
            entity.routeArrivalPlace = activity.routeDetails.arrivalPlace
            entity.routeDepartureDate = activity.routeDetails.departureDate
            entity.routeArrivalDate = activity.routeDetails.arrivalDate
            entity.routeCompany = activity.routeDetails.company
            entity.routeBookingNumber = activity.routeDetails.bookingNumber
            
            entity.hasReturnRoute = activity.hasReturnRoute
            entity.returnRouteTransportType = activity.returnRouteDetails.transportType
            entity.returnRouteFrom = activity.returnRouteDetails.from
            entity.returnRouteTo = activity.returnRouteDetails.to
            entity.returnRouteDeparturePlace = activity.returnRouteDetails.departurePlace
            entity.returnRouteArrivalPlace = activity.returnRouteDetails.arrivalPlace
            entity.returnRouteDepartureDate = activity.returnRouteDetails.departureDate
            entity.returnRouteArrivalDate = activity.returnRouteDetails.arrivalDate
            entity.returnRouteCompany = activity.returnRouteDetails.company
            entity.returnRouteBookingNumber = activity.returnRouteDetails.bookingNumber
            
            entity.orderIndex = Int16(index)
            entity.trip = tripEntity
        }
    }

    private func deleteOldActivities(for tripEntity: TripEntity) {
        guard let oldActivities = tripEntity.activities as? Set<TripActivityEntity> else {
            return
        }
        
        for activity in oldActivities {
            context.delete(activity)
        }
    }
    
    private func makeActivities(from entity: TripEntity) -> [TripActivity] {
        guard let activityEntities = entity.activities as? Set<TripActivityEntity>,
              !activityEntities.isEmpty else {
            return []
        }
        
        return activityEntities
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { activityEntity in
                let routeDetails = TransportSegment(
                    id: UUID(),
                    transportType: activityEntity.routeTransportType ?? "",
                    from: activityEntity.routeFrom ?? "",
                    to: activityEntity.routeTo ?? "",
                    departurePlace: activityEntity.routeDeparturePlace ?? "",
                    arrivalPlace: activityEntity.routeArrivalPlace ?? "",
                    departureDate: activityEntity.routeDepartureDate ?? Date(),
                    arrivalDate: activityEntity.routeArrivalDate ?? Date(),
                    company: activityEntity.routeCompany ?? "",
                    bookingNumber: activityEntity.routeBookingNumber ?? ""
                )
                
                let returnRouteDetails = TransportSegment(
                    id: UUID(),
                    transportType: activityEntity.returnRouteTransportType ?? "",
                    from: activityEntity.returnRouteFrom ?? "",
                    to: activityEntity.returnRouteTo ?? "",
                    departurePlace: activityEntity.returnRouteDeparturePlace ?? "",
                    arrivalPlace: activityEntity.returnRouteArrivalPlace ?? "",
                    departureDate: activityEntity.returnRouteDepartureDate ?? Date(),
                    arrivalDate: activityEntity.returnRouteArrivalDate ?? Date(),
                    company: activityEntity.returnRouteCompany ?? "",
                    bookingNumber: activityEntity.returnRouteBookingNumber ?? ""
                )
                
                return TripActivity(
                    id: activityEntity.id ?? UUID(),
                    title: activityEntity.title ?? "",
                    date: activityEntity.date ?? Date(),
                    hasTime: activityEntity.hasTime,
                    time: activityEntity.time ?? Date(),
                    location: activityEntity.location ?? "",
                    note: activityEntity.note ?? "",
                    bookingNumber: activityEntity.bookingNumber ?? "",
                    isBooked: activityEntity.isBooked,
                    hasRouteDetails: activityEntity.hasRouteDetails,
                    routeDetails: routeDetails,
                    hasReturnRoute: activityEntity.hasReturnRoute,
                    returnRouteDetails: returnRouteDetails
                )
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
    
    func deleteFolder(_ folder: TripFolder) {
        let tripRequest: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        tripRequest.predicate = NSPredicate(
            format: "folderID == %@",
            folder.id as CVarArg
        )
        
        do {
            let tripEntities = try context.fetch(tripRequest)
            
            for tripEntity in tripEntities {
                tripEntity.folderID = nil
            }
            
            let folderRequest: NSFetchRequest<TripFolderEntity> = TripFolderEntity.fetchRequest()
            
            folderRequest.predicate = NSPredicate(
                format: "id == %@",
                folder.id as CVarArg
            )
            
            let folderEntities = try context.fetch(folderRequest)
            
            if let folderEntity = folderEntities.first {
                context.delete(folderEntity)
            }
            
            saveContext()
        } catch {
            print("Failed to delete folder:", error)
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
    
    func moveTrip(_ trip: Trip, to folderID: UUID?) {
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
            
            entity.folderID = folderID
            saveContext()
        } catch {
            print("Failed to move trip:", error)
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
            segmentEntity.departurePlace = step.departurePlace
            segmentEntity.arrivalPlace = step.arrivalPlace
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
            segmentEntity.departurePlace = step.departurePlace
            segmentEntity.arrivalPlace = step.arrivalPlace
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
            departurePlace: entity.departurePlace ?? "",
            arrivalPlace: entity.arrivalPlace ?? "",
            departureDate: entity.departureDate ?? Date(),
            arrivalDate: entity.arrivalDate ?? Date(),
            company: entity.company ?? "",
            bookingNumber: entity.bookingNumber ?? ""
        )
        
        let routeSteps = makeRouteSteps(from: entity)
        
        let returnRouteSteps = makeReturnRouteSteps(from: entity)
        let activities = makeActivities(from: entity)
        
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
            folderID: entity.folderID,
            basicInfo: basicInfo,
            transportDetails: transportDetails,
            routeSteps: routeSteps,
            hotelDetails: hotelDetails,
            hasHotelDetails: entity.hasHotelDetails,
            hasHotelDates: entity.hasHotelDates,
            checklistItems: checklistItems,
            hasReturnTicket: entity.hasReturnTicket,
            returnRouteSteps: returnRouteSteps,
            activities: activities
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
                    departurePlace: segmentEntity.departurePlace ?? "",
                    arrivalPlace: segmentEntity.arrivalPlace ?? "",
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
                    departurePlace: segmentEntity.departurePlace ?? "",
                    arrivalPlace: segmentEntity.arrivalPlace ?? "",
                    departureDate: segmentEntity.departureDate ?? Date(),
                    arrivalDate: segmentEntity.arrivalDate ?? Date(),
                    company: segmentEntity.company ?? "",
                    bookingNumber: segmentEntity.bookingNumber ?? ""
                )
            }
    }
    
    func saveFolder(_ folder: TripFolder) {
        let entity = TripFolderEntity(context: context)
        
        entity.id = folder.id
        entity.name = folder.name
        entity.colorName = folder.colorName
        entity.createdAt = folder.createdAt
        
        saveContext()
    }

    func fetchFolders() -> [TripFolder] {
        let request: NSFetchRequest<TripFolderEntity> = TripFolderEntity.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        
        do {
            let entities = try context.fetch(request)
            
            return entities.map {
                TripFolder(
                    id: $0.id ?? UUID(),
                    name: $0.name ?? "",
                    colorName: $0.colorName ?? "blue",
                    createdAt: $0.createdAt ?? Date()
                )
            }
        } catch {
            print("Failed to fetch folders:", error)
            return []
        }
    }

    func deleteTripFolder(_ folder: TripFolder) {
        let request: NSFetchRequest<TripFolderEntity> = TripFolderEntity.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id == %@",
            folder.id as CVarArg
        )
        
        do {
            let entities = try context.fetch(request)
            
            if let entityToDelete = entities.first {
                context.delete(entityToDelete)
                saveContext()
            }
        } catch {
            print("Failed to delete folder:", error)
        }
    }
    
    func updateFolder(_ folder: TripFolder) {
        let request: NSFetchRequest<TripFolderEntity> = TripFolderEntity.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id == %@",
            folder.id as CVarArg
        )
        
        do {
            let entities = try context.fetch(request)
            
            guard let entity = entities.first else {
                return
            }
            
            entity.name = folder.name
            entity.colorName = folder.colorName
            entity.createdAt = folder.createdAt
            
            saveContext()
        } catch {
            print("Failed to update folder:", error)
        }
    }
    
    func removeFolderFromTrips(folderID: UUID) {
        let request: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "folderID == %@",
            folderID as CVarArg
        )
        
        do {
            let entities = try context.fetch(request)
            
            for entity in entities {
                entity.folderID = nil
            }
            
            saveContext()
        } catch {
            print("Failed to remove folder from trips:", error)
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
