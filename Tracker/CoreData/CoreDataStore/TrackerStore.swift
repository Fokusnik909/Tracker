//
//  TrackerStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import Foundation
import CoreData
import UIKit


final class TrackerStore {
    private let dataBase = DataBase.shared
    
    //Create
    func saveTracker(tracker: Tracker) {
        let data = dataBase.createEntity(entity: TrackerCoreData.self)
        dataBase.setTrackerCoreDataValues(data, from: tracker)
        dataBase.saveContext()
    }
    
    //Read
    func readTrackers() -> [TrackerCoreData] {
        dataBase.fetchEntities(entity: TrackerCoreData.self)
    }
    
    //Update
    func update(trackerCoreData: TrackerCoreData, tracker: Tracker) {
        dataBase.updateTracker(trackerCoreData, with: tracker)
    }
    
    //Delete
    func delete(tracker: TrackerCoreData) {
        dataBase.deleteEntity(entity: tracker)
    }
    
}
