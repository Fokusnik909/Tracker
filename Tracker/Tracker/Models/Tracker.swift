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
    var name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}

struct TrackerRecord: Identifiable {
    let id: UUID
    let date: Date
}

struct Emojis {
    static func randomEmoji() -> String {
        let emojis = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
        
        return emojis.randomElement()!
    }
}
