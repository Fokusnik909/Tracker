//
//  Tracker.swift
//  Tracker
//
//  Created by Артур  Арсланов on 29.06.2024.
//

import Foundation
import UIKit
 
struct Tracker: Identifiable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekdays]
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord: Identifiable {
    let id: UUID
    let date: Date
}

extension Tracker {
    init(from trackerCoreData: TrackerCoreData) {
        self.id = trackerCoreData.id ?? UUID()
        self.name = trackerCoreData.name ?? ""
        self.emoji = trackerCoreData.emoji ?? ""
        
        if let colorHex = trackerCoreData.color {
            self.color = UIColorMarshalling().color(from: colorHex)
        } else {
            self.color = .black 
        }
        if let scheduleData = trackerCoreData.schedule as? Data {
            self.schedule = (try? JSONDecoder().decode([Weekdays].self, from: scheduleData)) ?? []
        } else {
            self.schedule = []
        }
    }
}

struct Emojis {
    static func randomEmoji() -> String {
        let emojis = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
        
        return emojis.randomElement() ?? "💫"
    }
    
}
