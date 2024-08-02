//
//  AppDelegate.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DaysValueTransformer.register()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

    // MARK: - Core Data stack
    private let coreDataStack = CoreDataStack.shared
    
    var persistentContainer: NSPersistentContainer {
        return coreDataStack.persistentContainer
    }
    
    var viewContext: NSManagedObjectContext {
        return coreDataStack.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        coreDataStack.saveContext()
    }
}

