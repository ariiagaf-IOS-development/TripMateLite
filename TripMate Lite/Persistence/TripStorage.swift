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
        
        saveContext()
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
        
        let hotelDetails = HotelDetails(
            hotelName: entity.hotelName ?? "",
            address: entity.address ?? "",
            checkInDate: entity.checkInDate ?? Date(),
            checkOutDate: entity.checkOutDate ?? Date()
        )
        
        return Trip(
            id: entity.id ?? UUID(),
            basicInfo: basicInfo,
            transportDetails: transportDetails,
            hotelDetails: hotelDetails
        )
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
