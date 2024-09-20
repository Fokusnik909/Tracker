//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Артур  Арсланов on 29.07.2024.
//

import CoreData

final class DataBase {
    static let shared = DataBase()
    
    static func connect() {
        DaysValueTransformer.register()
    }
    
    private init() {
        _ = viewContext
    }
    
    
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data Model")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //Create
    func createEntity<T: NSManagedObject>(entity: T.Type) -> T {
        return T(context: viewContext)
    }
    
    //Read
    func fetchEntities<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try viewContext.fetch(fetchRequest) as! [T]
        } catch {
            print("Failed to fetch entities: \(error)")
            return []
        }
    }
    
    //Update
    
    //update tracker
    func updateTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        setTrackerCoreDataValues(trackerCoreData, from: tracker)
        saveContext()
    }
    
    //update category
    func updateCategory(category: TrackerCategoryCoreData, title: String) {
        category.title = title
        saveContext()
    }
    
    //Delete
    func deleteEntity<T: NSManagedObject>(entity: T) {
        viewContext.delete(entity)
        saveContext()
    }
    
     func setTrackerCoreDataValues(_ trackerCoreData: TrackerCoreData, from tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
         trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let emoji = trackerCoreData.emoji,
              let colorHex = trackerCoreData.color,
              let scheduleData = trackerCoreData.schedule as? Data,
              let schedule = try? JSONDecoder().decode([Weekdays].self, from: scheduleData)
        else {
            print("Некоторые свойства отсутствуют")
            return nil
        }
        let color = UIColorMarshalling.color(from: colorHex)
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
