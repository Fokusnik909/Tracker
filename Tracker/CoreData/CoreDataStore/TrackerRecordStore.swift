//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import Foundation
import CoreData

protocol TrackerRecordDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(trackerRecord: TrackerRecord) throws
    func delete(id: UUID, date: Date) throws
    func fetch() throws -> [TrackerRecord]
}

final class TrackerRecordStore: TrackerRecordDataStore {
    enum TrackerRecordStoreError: Error {
        case fetchFailed
        case deleteFailed
        case saveFailed
        case contextUnavailable
    }
    
    private let dataBase = DataBase.shared
    private let calendar = Calendar.current

    var managedObjectContext: NSManagedObjectContext? {
        return dataBase.viewContext
    }
    
    func add(trackerRecord: TrackerRecord) throws {
        guard managedObjectContext != nil else {
            throw TrackerRecordStoreError.contextUnavailable
        }
        
        let entity = dataBase.createEntity(entity: TrackerRecordCoreData.self)
        entity.id = trackerRecord.id
        entity.date = calendar.startOfDay(for: trackerRecord.date)
        
        dataBase.saveContext()
        print("TrackerRecord added: \(trackerRecord)")
    }

    func delete(id: UUID, date: Date) throws {
        guard let context = managedObjectContext else {
            throw TrackerRecordStoreError.contextUnavailable
        }
        
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@", id as NSUUID, startDate as NSDate, endDate as NSDate)
        
        do {
            let records = try context.fetch(request)
            print(records.count)
            if let recordToDelete = records.first {
                context.delete(recordToDelete)
                try context.save()
            } else {
                print("No TrackerRecord found to delete with id: \(id) and date: \(date)")
            }
        } catch {
            print("Failed to delete tracker entry: \(error)")
            throw TrackerRecordStoreError.deleteFailed
        }
    }

    func fetch() throws -> [TrackerRecord] {
        guard let context = managedObjectContext else {
            throw TrackerRecordStoreError.contextUnavailable
        }
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            let fetchedRecords = results.map { TrackerRecord(id: $0.id ?? UUID(), date: $0.date ?? Date()) }
            
            print("Fetched TrackerRecords: \(fetchedRecords)") 
            
            return fetchedRecords
        } catch {
                throw TrackerRecordStoreError.fetchFailed
        }
    }
    
    func isTrackerCompleted(id: UUID, date: Date) -> Bool {
        guard let context = managedObjectContext else {
            return false
        }
        
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@", id as NSUUID, startDate as NSDate, endDate as NSDate)
        
        do {
            let records = try context.fetch(request)
            return !records.isEmpty
        } catch {
            print("Ошибка при проверке завершённого трекера: \(error)")
            return false
        }
    }

}
