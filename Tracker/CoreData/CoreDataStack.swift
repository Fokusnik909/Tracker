//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Артур  Арсланов on 29.07.2024.
//

import CoreData

final class CoreDataStack {
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
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
