//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import UIKit
import CoreData

protocol TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func createCategory(_ category: TrackerCategory) throws
    func fetchAllCategories() -> [TrackerCategory]
}

class TrackerCategoryStore: TrackerCategoryDataStore {
    
     var managedObjectContext: NSManagedObjectContext? {
        return DataBase.shared.viewContext
    }
    
    private let dataBase = DataBase.shared
    
    //Create
    func createCategory(_ category: TrackerCategory) throws {
        let data = dataBase.createEntity(entity: TrackerCategoryCoreData.self)
        data.title = category.title
        
        dataBase.saveContext()
    }
    
    //Read
    func fetchAllCategories() -> [TrackerCategory] {
        let coreDataCategories = dataBase.fetchEntities(entity: TrackerCategoryCoreData.self)
        return coreDataCategories.map { convertToTrackerCategory($0) }
    }
    
    //Delete
    func delete(category: TrackerCategoryCoreData) {
        dataBase.deleteEntity(entity: category)
    }
    
    private func convertToTrackerCategory(_ coreData: TrackerCategoryCoreData) -> TrackerCategory {
        let title = coreData.title ?? ""
        let trackers = (coreData.trackers?.allObjects as? [TrackerCoreData] ?? []).map { Tracker(from: $0) }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
}
