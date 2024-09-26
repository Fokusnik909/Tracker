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

protocol TrackerManagerProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, category: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func deleteTrackers() throws
    func togglePin(for tracker: Tracker) throws
}


final class TrackerStoreManager: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
        case noTrackersFound
        case failedToAddTracker(Error)
        case failedToDeleteTracker(Error)
        case failedToUpdateTracker(Error)
        case failedToTogglePin(Error)
    }
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStoreProtocol
    private var insertedIndexes: IndexSet = []
    private var deletedIndexes: IndexSet = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    
    init(_ dataStore: TrackerDataStoreProtocol, delegate: TrackerStoreDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }
}

// MARK: - TrackerDataProviderProtocol
extension TrackerStoreManager: TrackerManagerProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCD = fetchedResultsController.object(at: indexPath)
        return DataBase.shared.tracker(from: trackerCD)
    }
    
    func addTracker(_ tracker: Tracker, category: TrackerCategory) throws {
        do {
            try dataStore.addTracker(tracker, category: category)
        } catch {
            throw DataProviderError.failedToAddTracker(error)
        }
    }
    
    func updateTracker(_ tracker: Tracker, category: String) throws {
        guard let trackerCoreData = fetchedResultsController.fetchedObjects?.first(where: { $0.id == tracker.id }) else {
            throw DataProviderError.noTrackersFound
        }
        
        dataStore.update(trackerCoreData, tracker: tracker)
        
        if let categoryCoreData = trackerCoreData.category {
            
            categoryCoreData.title = category
        }
        
        do {
            try dataStore.managedObjectContext?.save()
        } catch {
            throw DataProviderError.failedToUpdateTracker(error)
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            try dataStore.delete(tracker)
        } catch {
            throw DataProviderError.failedToDeleteTracker(error)
        }
    }
    
    func deleteTrackers() throws {
        guard let trackers = fetchedResultsController.fetchedObjects else {
            throw DataProviderError.noTrackersFound
        }
        
        for tracker in trackers {
            do {
                try dataStore.delete(tracker)
            } catch {
                throw DataProviderError.failedToDeleteTracker(error)
            }
        }
    }
    
    func togglePin(for tracker: Tracker) throws {
        guard let trackerCoreData = fetchedResultsController.fetchedObjects?.first(where: { $0.id == tracker.id }) else {
            throw DataProviderError.noTrackersFound
        }
        
        do {
            try dataStore.togglePin(for: trackerCoreData)
            
            print("Состояние закрепления трекера переключено на: \(trackerCoreData.isPinned)")
        } catch {
            throw DataProviderError.failedToUpdateTracker(error)
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
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes
        ))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath.item)
                
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath.item)
            }
        default:
            break
        }
    }
}
