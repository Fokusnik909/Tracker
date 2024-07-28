//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    //MARK: - Properties
    private let context: NSManagedObjectContext
    
    //MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = UIApplication.shared.delegate as! AppDelegate
        self.init(context: context.persistentContainer.viewContext)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryObject = TrackerCategoryCoreData(context: context)
        
        categoryObject.title = category.title
        let trackersSet = NSSet(array: category.trackers.map { tracker in
            let trackerObject = TrackerCoreData(context: context)
            trackerObject.id = tracker.id
            trackerObject.name = tracker.name
            trackerObject.color = UIColorMarshalling().hexString(from: tracker.color)
            trackerObject.emoji = tracker.emoji
            trackerObject.schedule = tracker.schedule.map { $0.rawValue } as NSObject
            return trackerObject
        })
        
        categoryObject.trackers = trackersSet
        
        try context.save()
    }
}
