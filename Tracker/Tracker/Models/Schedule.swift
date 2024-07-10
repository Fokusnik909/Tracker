//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 09.07.2024.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var description: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

struct WeekDayModel {
    let day: WeekDay
    var isSelected: Bool
}
