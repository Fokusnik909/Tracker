//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.07.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    //MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = UIApplication.shared.delegate as! AppDelegate
        self.init(context: context.persistentContainer.viewContext)
    }
    
    func addTrackerRecord(_ record: TrackerRecord) throws {
        let recordObject = TrackerRecordCoreData(context: context)
        
        recordObject.id = record.id
        recordObject.date = record.date
        
        try context.save()
    }
}
