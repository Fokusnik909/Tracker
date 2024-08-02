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
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let categoryStore: TrackerCategoryStore
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject
        
    }
    
    func createTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let colorHex = trackerCoreData.color,
              let emoji = trackerCoreData.emoji,
              let schedule = trackerCoreData.schedule as? [Int]
        else {
            throw TrackerStoreError.decodingErrorInvalidData
        }
        
        let color = UIColorMarshalling().color(from: colorHex)
        let weekdays = schedule.compactMap { Weekdays(rawValue: $0) }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: weekdays)
    }
    

}

//enum TrackerStoreError: Error {
//    case decodingErrorInvalidData
//}
//
//protocol TrackerStoreDelegate: AnyObject {
//    func didUpdate()
//}
//
//protocol TrackerStoreProtocol {
//    var trackerCount: Int { get }
//    var sectionCount: Int { get }
//    func numberOfRows(in section: Int) -> Int
//    func headerLabel(for section: Int) -> String?
//    func tracker(at indexPath: IndexPath) -> Tracker?
//    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
//}
//
//final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
//    
//    weak var delegate: TrackerStoreDelegate?
//    
//    private let context: NSManagedObjectContext
//    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//        fetchedResultsController.delegate = self
//        try? fetchedResultsController.performFetch()
//    }
//    
//    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
//        
//        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
//        
//        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true)
//        ]
//        
//        let fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,
//            sectionNameKeyPath: "category.title",
//            cacheName: nil
//        )
//        
//        return fetchedResultsController
//    }()
//    
//    func createTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
//        guard let id = trackerCoreData.id,
//              let name = trackerCoreData.name,
//              let colorHex = trackerCoreData.color,
//              let emoji = trackerCoreData.emoji,
//              let schedule = trackerCoreData.schedule as? [Int] else {
//            throw TrackerStoreError.decodingErrorInvalidData
//        }
//        
//        let color = UIColorMarshalling().color(from: colorHex)
//        let weekdays = schedule.compactMap { Weekdays(rawValue: $0) }
//        
//        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: weekdays)
//    }
//    
//    private func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
//        trackerCoreData.id = tracker.id
//        trackerCoreData.name = tracker.name
//        trackerCoreData.color = UIColorMarshalling().hexString(from: tracker.color)
//        trackerCoreData.emoji = tracker.emoji
//        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject
//    }
//    
//    func loadFilteredTrackers(date: Date, searchString: String) throws {
//        var predicates = [NSPredicate]()
//        
//        let weekdayIndex = Calendar.current.component(.weekday, from: date)
//        let iso860WeekdayIndex = weekdayIndex > 1 ? weekdayIndex - 2 : weekdayIndex + 5
//        
//        var regex = ""
//        for index in 0..<7 {
//            regex += (index == iso860WeekdayIndex) ? "1" : "."
//        }
//        
//        let schedulePredicate = NSPredicate(
//            format: "(%K == nil) OR (%K MATCHES[c] %@)",
//            #keyPath(TrackerCoreData.schedule), #keyPath(TrackerCoreData.schedule), regex
//        )
//        predicates.append(schedulePredicate)
//        
//        if !searchString.isEmpty {
//            let searchPredicate = NSPredicate(
//                format: "%K CONTAINS[cd] %@",
//                #keyPath(TrackerCoreData.name), searchString
//            )
//            predicates.append(searchPredicate)
//        }
//        
//        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        
//        try fetchedResultsController.performFetch()
//        
//        delegate?.didUpdate()
//    }
//}
//
//extension TrackerStore: TrackerStoreProtocol {
//    var trackerCount: Int {
//        fetchedResultsController.fetchedObjects?.count ?? 0
//    }
//    
//    var sectionCount: Int {
//        fetchedResultsController.sections?.count ?? 0
//    }
//    
//    func numberOfRows(in section: Int) -> Int {
//        fetchedResultsController.sections?[section].numberOfObjects ?? 0
//    }
//    
//    func headerLabel(for section: Int) -> String? {
//        fetchedResultsController.sections?[section].name
//    }
//    
//    func tracker(at indexPath: IndexPath) -> Tracker? {
//        let trackerCoreData = fetchedResultsController.object(at: indexPath)
//        do {
//            let tracker = try createTracker(from: trackerCoreData)
//            return tracker
//        } catch {
//            return nil
//        }
//    }
//    
//    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
//        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
//        categoryRequest.predicate = NSPredicate(format: "title == %@", category.title)
//        
//        guard let categoryCoreData = try context.fetch(categoryRequest).first else {
//            throw TrackerStoreError.decodingErrorInvalidData
//        }
//        
//        let trackerCoreData = TrackerCoreData(context: context)
//        trackerCoreData.id = tracker.id
//        trackerCoreData.name = tracker.name
//        trackerCoreData.color = UIColorMarshalling().hexString(from: tracker.color)
//        trackerCoreData.emoji = tracker.emoji
//        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject
//        trackerCoreData.category = categoryCoreData
//        
//        try context.save()
//    }
//}


//
//final class TrackerStore: NSObject {
//    private let context: NSManagedObjectContext
//    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
//
//    weak var delegate: TrackerStoreDelegate?
//    private var insertedIndexes: IndexSet?
//    private var deletedIndexes: IndexSet?
//    private var updatedIndexes: IndexSet?
//    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
//
//    init(context: NSManagedObjectContext) throws {
//        self.context = context
//        super.init()
//
//        let fetchRequest = TrackerCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(key: "name", ascending: true)
//        ]
//        let controller = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        controller.delegate = self
//        self.fetchedResultsController = controller
//        try controller.performFetch()
//    }
//
//    var trackers: [Tracker] {
//        guard
//            let objects = self.fetchedResultsController.fetchedObjects,
//            let trackers = try? objects.map({ try self.tracker(from: $0) })
//        else { return [] }
//        return trackers
//    }
//
//    func addNewTracker(_ tracker: Tracker) throws {
//        let trackerCoreData = TrackerCoreData(context: context)
//        updateExistingTracker(trackerCoreData, with: tracker)
//        try context.save()
//    }
//
//    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
//        trackerCoreData.id = tracker.id
//        trackerCoreData.name = tracker.name
//        trackerCoreData.color = UIColorMarshalling().hexString(from: tracker.color)
//        trackerCoreData.emoji = tracker.emoji
//        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject
//    }
//
//    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
//        guard let id = trackerCoreData.id,
//              let name = trackerCoreData.name,
//              let colorHex = trackerCoreData.color,
//              let emoji = trackerCoreData.emoji,
//              let schedule = trackerCoreData.schedule as? [Int]
//        else {
//            throw TrackerStoreError.decodingErrorInvalidData
//        }
//
//        let color = UIColorMarshalling().color(from: colorHex)
//        let weekdays = schedule.compactMap { Weekdays(rawValue: $0) }
//        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: weekdays)
//    }
//}
//
//extension TrackerStore: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
//        updatedIndexes = IndexSet()
//        movedIndexes = Set<TrackerStoreUpdate.Move>()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.store(
//            self,
//            didUpdate: TrackerStoreUpdate(
//                insertedIndexes: insertedIndexes!,
//                deletedIndexes: deletedIndexes!,
//                updatedIndexes: updatedIndexes!,
//                movedIndexes: movedIndexes!
//            )
//        )
//        insertedIndexes = nil
//        deletedIndexes = nil
//        updatedIndexes = nil
//        movedIndexes = nil
//    }
//
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange anObject: Any,
//        at indexPath: IndexPath?,
//        for type: NSFetchedResultsChangeType,
//        newIndexPath: IndexPath?
//    ) {
//        switch type {
//        case .insert:
//            guard let indexPath = newIndexPath else { fatalError() }
//            insertedIndexes?.insert(indexPath.item)
//        case .delete:
//            guard let indexPath = indexPath else { fatalError() }
//            deletedIndexes?.insert(indexPath.item)
//        case .update:
//            guard let indexPath = indexPath else { fatalError() }
//            updatedIndexes?.insert(indexPath.item)
//        case .move:
//            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
//            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
//        @unknown default:
//            fatalError()
//        }
//    }
//}
