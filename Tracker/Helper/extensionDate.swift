//
//  extensionDate.swift
//  Tracker
//
//  Created by Артур  Арсланов on 15.07.2024.
//

import Foundation

extension Date {
    var dayOfWeek: Int {
        return Calendar.current.component(.weekday, from: self)
    }
}
