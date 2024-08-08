//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let dataBase = DataBase.shared
    
    // Create
    func saveRecord(trackerRecord: TrackerRecord, for tracker: TrackerCoreData) {
        let recordData = dataBase.createEntity(entity: TrackerRecordCoreData.self)
        recordData.id = trackerRecord.id
        recordData.date = trackerRecord.date
        recordData.tracker = tracker
        dataBase.saveContext()
    }
    
    // Read
    func fetchRecords(for tracker: TrackerCoreData) -> [TrackerRecordCoreData] {
        let predicate = NSPredicate(format: "tracker == %@", tracker)
        return dataBase.fetchEntities(entity: TrackerRecordCoreData.self, predicate: predicate)
    }
    
    func fetchAllRecords() -> [TrackerRecordCoreData] {
        return dataBase.fetchEntities(entity: TrackerRecordCoreData.self)
    }
    
    // Update
    func update(recordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        recordCoreData.id = trackerRecord.id
        recordCoreData.date = trackerRecord.date
        dataBase.saveContext()
    }
    
    // Delete
    func delete(record: TrackerRecordCoreData) {
        dataBase.deleteEntity(entity: record)
    }
    
}
