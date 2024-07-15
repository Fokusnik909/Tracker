//
//  TrackerService.swift
//  Tracker
//
//  Created by Артур  Арсланов on 10.07.2024.
//

import Foundation

//final class TrackerService {
//    var currentTracker: Tracker?
//    
//    static let shared = TrackerService()
//    
//    private init() {}
//    
//    var categories: [TrackerCategory] = [
//        TrackerCategory(title: "Домашний уют", trackers: [] )
//    ]
//    
//    var completedTrackers: [TrackerRecord] = []
//    
//    func append(_ tracker: Tracker) {
//            if let index = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
//                // Категория с трекером найдена, обновляем трекер в этой категории
//                let category = categories[index]
//                var trackers = category.trackers
//                if let trackerIndex = trackers.firstIndex(where: { $0.id == tracker.id }) {
//                    trackers[trackerIndex] = tracker
//                } else {
//                    trackers.append(tracker)
//                }
//                let updatedCategory = TrackerCategory(title: category.title, trackers: trackers)
//                categories[index] = updatedCategory
//            } else {
//                // Категория с трекером не найдена, добавляем трекер в первую категорию
//                if categories.isEmpty {
//                    // Если категорий нет, создаем новую категорию и добавляем трекер
//                    let newCategory = TrackerCategory(title: "Новая категория", trackers: [tracker])
//                    categories.append(newCategory)
//                } else {
//                    // Если категории есть, добавляем трекер в первую категорию
//                    let category = categories[0]
//                    var trackers = category.trackers
//                    trackers.append(tracker)
//                    let updatedCategory = TrackerCategory(title: category.title, trackers: trackers)
//                    categories[0] = updatedCategory
//                }
//            }
//        }
//    
//    func remove(_ tracker: Tracker) {
//        if let index = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
//            let category = categories[index]
//            let trackers = category.trackers.filter { $0.id != tracker.id }
//            
//            let updatedCategory = TrackerCategory(title: category.title, trackers: trackers)
//            
//            categories[index] = updatedCategory
//        }
//    }
//}
