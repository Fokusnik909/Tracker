//
//  TrackerStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import Foundation
import CoreData
import UIKit


protocol DataStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func save(_ tracker: Tracker) throws
    func readTrackers() -> [TrackerCoreData]
    func update(_ trackerCoreData: TrackerCoreData, tracker: Tracker)
    func delete(_ tracker: TrackerCoreData) throws
}

final class TrackerStore: DataStoreProtocol {
    private let dataBase = DataBase.shared
    
    var managedObjectContext: NSManagedObjectContext? {
        return dataBase.viewContext
    }

    func save(_ tracker: Tracker) {
        let data = dataBase.createEntity(entity: TrackerCoreData.self)
        dataBase.setTrackerCoreDataValues(data, from: tracker)
        dataBase.saveContext()
    }

    func readTrackers() -> [TrackerCoreData] {
        return dataBase.fetchEntities(entity: TrackerCoreData.self)
    }

    func update(_ trackerCoreData: TrackerCoreData, tracker: Tracker) {
        dataBase.updateTracker(trackerCoreData, with: tracker)
    }

    func delete(_ tracker: TrackerCoreData) {
        dataBase.deleteEntity(entity: tracker)
    }
}
