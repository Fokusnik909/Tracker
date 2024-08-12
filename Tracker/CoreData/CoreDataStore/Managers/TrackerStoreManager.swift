//
//  TrackerStoreManager.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.08.2024.
//

import Foundation
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func sectionTitle(for section: Int) -> String?
    func addTracker(_ tracker: Tracker) throws
    func deleteTracker(at indexPath: IndexPath) throws
}


final class TrackerStoreManager: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: DataStoreProtocol
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        printAllCategories()
        return fetchedResultsController
    }()
    
    init(_ dataStore: DataStoreProtocol, delegate: TrackerStoreDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }
    
    func printAllCategories() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                if let category = result.category {
                    print("Category title: \(category.title ?? "nil")")
                } else {
                    print("Category is nil for result: \(result)")
                }
            }
        } catch {
            print("Failed to fetch TrackerCoreData: \(error)")
        }
    }
}

// MARK: - TrackerDataProviderProtocol
extension TrackerStoreManager: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func sectionTitle(for section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name.isEmpty ?? true ? "Без категории" : sectionInfo?.name
    }

    func addTracker(_ tracker: Tracker) throws {
        do {
            try dataStore.save(tracker)
        } catch {
            print("Failed to add tracker: \(error)")
            throw error
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            try dataStore.delete(tracker)
        } catch {
            print("Failed to delete tracker: \(error)")
            throw error
        }
    }
    
    func printSectionTitles() {
        guard let sections = fetchedResultsController.sections else { return }
        for (index, section) in sections.enumerated() {
            print("Section \(index): \(section.name)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStoreManager: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath.item)
            }
        default:
            break
        }
    }
}
