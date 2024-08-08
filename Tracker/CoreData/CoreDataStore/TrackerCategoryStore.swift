//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case categoryNotFound
    case decodingErrorInvalidData
}

class TrackerCategoryStore {
    private var context: NSManagedObjectContext {
        return DataBase.shared.viewContext
    }
    
    private let dataBase = DataBase.shared
    
    //Create
    func saveCategory(title: String) {
        let data = dataBase.createEntity(entity: TrackerCategoryCoreData.self)
        data.title = title
        dataBase.saveContext()
    }
    
    //Read
    func getCategory() -> [TrackerCategoryCoreData] {
        dataBase.fetchEntities(entity: TrackerCategoryCoreData.self)
    }
    
    //Update
    func update(category: TrackerCategoryCoreData, title: String) {
        dataBase.updateCategory(category: category, title: title)
    }
    
    //Delete
    func delete(category: TrackerCategoryCoreData) {
        dataBase.deleteEntity(entity: category)
    }
    
}
