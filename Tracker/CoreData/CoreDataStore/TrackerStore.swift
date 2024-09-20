//
//  TrackerStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import Foundation
import CoreData


protocol TrackerDataStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func addTracker(_ tracker: Tracker, category: TrackerCategory) throws
    func readTrackers() -> [TrackerCoreData]
    func update(_ trackerCoreData: TrackerCoreData, tracker: Tracker)
    func delete(_ tracker: TrackerCoreData) throws
}

final class TrackerStore: TrackerDataStoreProtocol {
    private let dataBase = DataBase.shared
    
    var managedObjectContext: NSManagedObjectContext? {
        return dataBase.viewContext
    }
    
    
    func addTracker(_ tracker: Tracker, category: TrackerCategory) throws {
        guard let context = managedObjectContext else {
            throw NSError(domain: "TrackerStoreError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Managed object context is nil."])
        }

        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)

        let categoryDB: TrackerCategoryCoreData
        do {
            if let existingCategory = try context.fetch(fetchRequest).first {
                categoryDB = existingCategory
            } else {
                categoryDB = TrackerCategoryCoreData(context: context)
                categoryDB.title = category.title
            }
        } catch {
            print("Error fetching or creating category: \(error.localizedDescription)")
            throw error
        }

        let trackerDB = TrackerCoreData(context: context)
        trackerDB.id = tracker.id
        trackerDB.name = tracker.name
        trackerDB.emoji = tracker.emoji
        trackerDB.color = UIColorMarshalling.hexString(from: tracker.color)

        trackerDB.schedule = tracker.schedule as NSObject

        trackerDB.category = categoryDB
        categoryDB.addToTrackers(trackerDB)

        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Чтение всех трекеров
    func readTrackers() -> [TrackerCoreData] {
        return dataBase.fetchEntities(entity: TrackerCoreData.self)
    }
    
    // Обновление трекера
    func update(_ trackerCoreData: TrackerCoreData, tracker: Tracker) {
        dataBase.updateTracker(trackerCoreData, with: tracker)
    }
    
    // Удаление трекера
    func delete(_ tracker: TrackerCoreData) throws {
        dataBase.deleteEntity(entity: tracker)
        dataBase.saveContext()
    }
    
    //MARK: - Private Methods
    // Функция для поиска или создания категории
    private func createOrFetchCategory(withName categoryName: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        
        do {
            if let category = try managedObjectContext?.fetch(fetchRequest).first {
                return category
            } else {
                let newCategory = TrackerCategoryCoreData(context: managedObjectContext!)
                newCategory.title = categoryName
                return newCategory
            }
        } catch {
            print("Error fetching or creating category: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Функция для создания трекера
    private func createTracker(tracker: Tracker, inCategory category: TrackerCategoryCoreData) -> TrackerCoreData {
        let data = dataBase.createEntity(entity: TrackerCoreData.self)
        dataBase.setTrackerCoreDataValues(data, from: tracker)
        data.category = category
        return data
    }
}
