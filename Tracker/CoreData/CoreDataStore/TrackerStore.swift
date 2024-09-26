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
    func togglePin(for tracker: TrackerCoreData) throws
}


final class TrackerStore: TrackerDataStoreProtocol {
    private let dataBase = DataBase.shared
    
    var managedObjectContext: NSManagedObjectContext? {
        return dataBase.viewContext
    }
    
    // Добавление трекера
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
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
        
        do {
            try managedObjectContext?.save()
        } catch {
            print("Error saving updated tracker: \(error.localizedDescription)")
        }
    }
    
    // Удаление трекера
    func delete(_ tracker: TrackerCoreData) throws {
        guard let context = managedObjectContext else {
            throw NSError(domain: "TrackerStoreError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Managed object context is nil."])
        }
        context.delete(tracker)
        try context.save()
    }
    
    // MARK: - Fetching Methods
    public func fetchTrackers(by date: Date) -> [TrackerCoreData]? {
        guard let context = managedObjectContext else { return nil }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "ANY records.date >= %@ AND ANY records.date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching trackers: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func fetchCompleteTrackers(by date: Date) -> [TrackerCoreData]? {
        guard let context = managedObjectContext else { return nil }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "ANY records.date >= %@ AND ANY records.date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching complete trackers: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func fetchIncompleteTrackers(by date: Date) -> [TrackerCoreData]? {
        guard let context = managedObjectContext else { return nil }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let noRecordForDatePredicate = NSPredicate(format: "SUBQUERY(records, $record, $record.date >= %@ AND $record.date < %@).@count == 0", startOfDay as NSDate, endOfDay as NSDate)
        
        let noRecordsPredicate = NSPredicate(format: "records.@count == 0")
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [noRecordsPredicate, noRecordForDatePredicate])
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = compoundPredicate
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching incomplete trackers: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Закрепление/открепление трекера
    func togglePin(for tracker: TrackerCoreData) throws {
        guard let context = managedObjectContext else {
            throw NSError(domain: "TrackerStoreError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Managed object context is nil."])
        }
        
        print("Текущее значение isPinned: \(tracker.isPinned)") 
        tracker.isPinned.toggle()
        print("Новое значение isPinned: \(tracker.isPinned)")
        
        do {
            try context.save()
        } catch {
            print("Error saving pin state: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Private Methods
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
