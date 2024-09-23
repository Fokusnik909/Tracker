//
//  TrackerCategoryStoreManager.swift
//  Tracker
//
//  Created by Артур  Арсланов on 15.08.2024.
//

import Foundation
import CoreData

struct TrackerCategoryUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

protocol TrackerCategoryManagerProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategory?
    func createCategory(_ category: TrackerCategory) throws
    func deleteCategory(with title: String) throws
    func fetchCategories() -> [TrackerCategory]
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws
}

protocol TrackerCategoryManagerDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryUpdate)
}

final class TrackerCategoryStoreManager: NSObject {
    enum TrackerCategoryErrors: Error {
        case failedToInitializeContext
        case failedToCreateCategory
        case failedToDeleteCategory
        case failedToUpdateCategory
        case categoryNotFound
    }

    
    weak var delegate: TrackerCategoryManagerDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    private var insertedIndexes: IndexSet = []
    private var deletedIndexes: IndexSet = []
    private var updatedIndexes: IndexSet = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    init(trackerCategoryStore: TrackerCategoryDataStore, delegate: TrackerCategoryManagerDelegate) throws {
        guard let context = trackerCategoryStore.managedObjectContext else {
            throw TrackerCategoryErrors.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackerCategoryDataStore = trackerCategoryStore
    }
    
}

extension TrackerCategoryStoreManager: TrackerCategoryManagerProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let title = trackerCategoryCoreData.title,
              let trackerCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] else {
            return nil
        }
        
        let trackers = trackerCoreData.map { Tracker(from: $0) }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func createCategory(_ category: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.createCategory(category)
        } catch {
            throw TrackerCategoryErrors.failedToCreateCategory
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        return trackerCategoryDataStore.fetchAllCategories()
    }
    
    func deleteCategory(with title: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(request)
            guard let categoryToDelete = results.first as? NSManagedObject else {
                throw TrackerCategoryErrors.categoryNotFound
            }
            context.delete(categoryToDelete)
            try context.save()
        } catch {
            throw TrackerCategoryErrors.failedToDeleteCategory
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let results = try context.fetch(request)
            guard let existingCategory = results.first as? TrackerCategoryCoreData else {
                throw TrackerCategoryErrors.categoryNotFound
            }
            existingCategory.title = newTitle
            try context.save()
        } catch {
            throw TrackerCategoryErrors.failedToUpdateCategory
        }
    }
}


extension TrackerCategoryStoreManager: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
        updatedIndexes.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerCategoryUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes
        )
        delegate?.didUpdate(update)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath.item)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes.insert(indexPath.item)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                deletedIndexes.insert(indexPath.item)
                insertedIndexes.insert(newIndexPath.item)
            }
        @unknown default:
            fatalError("Unknown change type encountered.")
        }
    }
}
