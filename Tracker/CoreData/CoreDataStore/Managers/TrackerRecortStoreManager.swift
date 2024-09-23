//
//  TrackerRecortStoreManager.swift
//  Tracker
//
//  Created by Артур  Арсланов on 15.08.2024.
//

import Foundation
import CoreData

struct TrackerRecordStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerRecordManagerProtocol {
    func add(trackerRecord: TrackerRecord) throws
    func delete(id: UUID, date: Date) throws
    func fetch() throws -> [TrackerRecord]
}

protocol TrackerRecordManagerDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordStoreUpdate)
}

final class TrackerRecordDataManager: NSObject {
    
    // MARK: - Errors
    enum TrackerRecordDataManagerError: Error {
        case initializationFailed
        case fetchFailed(Error)
        case addFailed(Error)
        case deleteFailed(Error)
    }
    
    // MARK: - Public Properties
    weak var delegate: TrackerRecordManagerDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerRecordDataStore: TrackerRecordDataStore
    private var insertedIndexes = IndexSet()
    private var deletedIndexes = IndexSet()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Failed to perform fetch: \(error)")
        }
        return fetchedResultController
    }()
    
    // MARK: - Init
    init(trackerRecordStore: TrackerRecordDataStore, delegate: TrackerRecordManagerDelegate) throws {
        guard let context = trackerRecordStore.managedObjectContext else {
            throw TrackerRecordDataManagerError.initializationFailed
        }
        self.delegate = delegate
        self.context = context
        self.trackerRecordDataStore = trackerRecordStore
    }
}

// MARK: - TrackerRecordDataProviderProtocol
extension TrackerRecordDataManager: TrackerRecordManagerProtocol {
    
    func add(trackerRecord: TrackerRecord) throws {
        do {
            try trackerRecordDataStore.add(trackerRecord: trackerRecord)
            
            let currentCount = UserDefaults.standard.integer(forKey: "completedTrackers")
            UserDefaults.standard.setValue(currentCount + 1, forKey: "completedTrackers")
        } catch {
            throw TrackerRecordDataManagerError.addFailed(error)
        }
    }
    
    func delete(id: UUID, date: Date) throws {
        do {
            try trackerRecordDataStore.delete(id: id, date: date)
            
            let currentCount = UserDefaults.standard.integer(forKey: "completedTrackers")
            if currentCount > 0 {
                UserDefaults.standard.setValue(currentCount - 1, forKey: "completedTrackers")
            }
        } catch {
            throw TrackerRecordDataManagerError.deleteFailed(error)
        }
    }
    
    func fetch() throws -> [TrackerRecord] {
        do {
            return try trackerRecordDataStore.fetch()
        } catch {
            throw TrackerRecordDataManagerError.fetchFailed(error)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordDataManager: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerRecordStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes
            )
        )
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath.row)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath.row)
            }
        default:
            break
        }
    }
}

