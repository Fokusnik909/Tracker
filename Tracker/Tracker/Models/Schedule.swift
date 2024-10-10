//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 09.07.2024.
//

import Foundation

enum Weekdays: Int, CaseIterable, Codable {
    
    static func from(date: Date) -> Weekdays? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
    
    case monday 
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var description: String {
        switch self {
        case .monday: return NSLocalizedString(DictionaryString.scheduleMonday, comment: "")
        case .tuesday: return NSLocalizedString(DictionaryString.scheduleTuesday, comment: "")
        case .wednesday: return NSLocalizedString(DictionaryString.scheduleWednesday, comment: "")
        case .thursday: return NSLocalizedString(DictionaryString.scheduleThursday, comment: "")
        case .friday: return NSLocalizedString(DictionaryString.scheduleFriday, comment: "")
        case .saturday: return NSLocalizedString(DictionaryString.scheduleSaturday, comment: "")
        case .sunday: return NSLocalizedString(DictionaryString.scheduleSunday, comment: "")
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return NSLocalizedString(DictionaryString.scheduleShortMonday, comment: "")
        case .tuesday: return NSLocalizedString(DictionaryString.scheduleShortTuesday, comment: "")
        case .wednesday: return NSLocalizedString(DictionaryString.scheduleShortWednesday, comment: "")
        case .thursday: return NSLocalizedString(DictionaryString.scheduleShortThursday, comment: "")
        case .friday: return NSLocalizedString(DictionaryString.scheduleShortFriday, comment: "")
        case .saturday: return NSLocalizedString(DictionaryString.scheduleShortSaturday, comment: "")
        case .sunday: return NSLocalizedString(DictionaryString.scheduleShortSunday, comment: "")
        }
    }
}
