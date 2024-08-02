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
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchCategoryCoreData(for id: UUID) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        let results = try context.fetch(request)
        guard let categoryCoreData = results.first else {
            throw TrackerStoreError.categoryNotFound
        }
        return categoryCoreData
    }
    
    func createCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = categoryCoreData.title,
              let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData]
        else {
            throw TrackerStoreError.decodingErrorInvalidData
        }
        
        let trackers = try trackersCoreData.map { try TrackerStore(context: context).createTracker(from: $0) }
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func fetchAllCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoryCoreDataArray = try context.fetch(request)
        return try categoryCoreDataArray.map { try createCategory(from: $0) }
    }
    
}

//enum StoreError: Error {
//    case decodeError
//}
//
//final class TrackerCategoryStore {
//    
//    private let context: NSManagedObjectContext
//    
//    var categories = [TrackerCategory]()
//    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        do {
//            try setupCategories(with: context)
//        } catch {
//            print(error)
//        }
//    }
//    
//    private func setupCategories(with context: NSManagedObjectContext) throws {
//        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
//        let categoryResult = try context.fetch(categoryRequest)
//        
//        if categoryResult.isEmpty {
//            let categoriesToCreate = [
//                TrackerCategory(title: "Домашний уют", trackers: [])
//            ]
//            categoriesToCreate.forEach { category in
//                let categoryCoreData = TrackerCategoryCoreData(context: context)
//                categoryCoreData.title = category.title
//            }
//            try context.save()
//            return
//        }
//        
//        categories = try categoryResult.map { try makeCategory(from: $0) }
//    }
//    
//    private func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
//        guard let title = coreData.title else {
//            throw TrackerStoreError.decodingErrorInvalidData
//        }
//        
//        let trackers: [Tracker] = (coreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap { try? createTracker(from: $0) } ?? []
//        return TrackerCategory(title: title, trackers: trackers)
//    }
//    
//    private func createTracker(from coreData: TrackerCoreData) throws -> Tracker {
//        guard let id = coreData.id,
//              let name = coreData.name,
//              let colorHex = coreData.color,
//              let emoji = coreData.emoji,
//              let schedule = coreData.schedule as? [Int] else {
//            throw TrackerStoreError.decodingErrorInvalidData
//        }
//        
//        let color = UIColorMarshalling().color(from: colorHex)
//        let weekdays = schedule.compactMap { Weekdays(rawValue: $0) }
//        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: weekdays)
//    }
//}
