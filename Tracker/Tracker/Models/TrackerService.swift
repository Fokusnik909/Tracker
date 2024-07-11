//
//  TrackerService.swift
//  Tracker
//
//  Created by Артур  Арсланов on 10.07.2024.
//

import Foundation

final class TrackerService {
    private(set) var selectedDay: Set<WeekDay> = []
    
    
    func add(_ day: WeekDay) {
        self.selectedDay.insert(day)
    }
}
