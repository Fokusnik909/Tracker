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
    let isPinned: Bool
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
            self.color = UIColorMarshalling.color(from: colorHex)
        } else {
            self.color = .ypBlack
        }
        
        self.schedule = trackerCoreData.schedule as? [Weekdays] ?? [Weekdays.monday]
        self.isPinned = trackerCoreData.isPinned
    }
}

struct Emojis {
    static func randomEmoji() -> String {
        let emojis = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
        
        return emojis.randomElement() ?? "💫"
    }
    
}

//extension Tracker {
//    init(from trackerCoreData: TrackerCoreData) {
//        self.id = trackerCoreData.id ?? UUID()
//        self.name = trackerCoreData.name ?? ""
//        self.emoji = trackerCoreData.emoji ?? ""
//
//        if let colorHex = trackerCoreData.color {
//            self.color = UIColorMarshalling.color(from: colorHex)
//        } else {
//            self.color = .ypBlack
//        }
//
//        if let scheduleData = trackerCoreData.schedule as? NSData {
//            do {
//                // Преобразуем NSData в Data перед декодированием
//                let data = Data(referencing: scheduleData)
//                self.schedule = try JSONDecoder().decode([Weekdays].self, from: data)
//                print("Декодированное расписание: \(self.schedule)")
//            } catch {
//                print("Ошибка при декодировании расписания: \(error.localizedDescription)")
//                self.schedule = [Weekdays.monday]
//            }
//        } else if let scheduleArray = trackerCoreData.schedule as? [Weekdays] {
//            self.schedule = scheduleArray
//        } else {
//            print("Ошибка: расписание отсутствует или неверного типа.")
//            self.schedule = [Weekdays.monday]
//        }
//    }
//}
