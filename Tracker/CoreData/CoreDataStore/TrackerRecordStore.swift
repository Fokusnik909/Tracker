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
    func delete(trackerRecord: TrackerRecord) throws
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

    var managedObjectContext: NSManagedObjectContext? {
        return dataBase.viewContext
    }
    
    func add(trackerRecord: TrackerRecord) throws {
        guard managedObjectContext != nil else {
            throw TrackerRecordStoreError.contextUnavailable
        }
        
        let entity = dataBase.createEntity(entity: TrackerRecordCoreData.self)
        entity.id = trackerRecord.id
        entity.date = trackerRecord.date
        
        dataBase.saveContext()
        
    }

    func delete(trackerRecord: TrackerRecord) throws {
        guard let context = managedObjectContext else {
            throw TrackerRecordStoreError.contextUnavailable
        }
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.id as CVarArg, trackerRecord.date as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let recordToDelete = results.first {
                context.delete(recordToDelete)
                do {
                    try context.save()
                } catch {
                    context.rollback() 
                    throw TrackerRecordStoreError.saveFailed
                }
            } else {
                throw TrackerRecordStoreError.deleteFailed
            }
        } catch {
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
            return results.map { TrackerRecord(id: $0.id ?? UUID(), date: $0.date ?? Date()) }
        } catch {
            throw TrackerRecordStoreError.fetchFailed
        }
    }
}
