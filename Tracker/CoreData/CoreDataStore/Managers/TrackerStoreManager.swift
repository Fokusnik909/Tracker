//
//  TrackerStoreManager.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.08.2024.
//

import Foundation
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: Tracker) throws
    func delete(_ record: NSManagedObject) throws
}


protocol TrackerStoreProtocol {
//    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerLabelInSection(_ section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws
}

final class TrackerStoreManager: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
}
