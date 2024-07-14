//
//  TrackerService.swift
//  Tracker
//
//  Created by Артур  Арсланов on 10.07.2024.
//

import Foundation

final class TrackerService {
    var currentTracker: Tracker?
    
    static let shared = TrackerService()
    
    private init() {}
    
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют!", trackers: [] )
    ]
    
    
    var completedTrackers: [TrackerRecord] = []
    
    func append(_ tracker: Tracker) {
        
        if let index = categories[0].trackers.firstIndex(where: { $0.id == tracker.id}) {
            categories[0].trackers[index] = tracker
        } else {
            categories[0].trackers.append(tracker)
        }
    }
    
    func remove(_ tracker: Tracker) {
        categories[0].trackers.removeAll { $0.id == tracker.id }
    }
}
