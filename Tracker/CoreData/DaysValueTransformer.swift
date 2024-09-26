//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Артур  Арсланов on 29.07.2024.
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Weekdays] else { return nil }
        do {
            let data = try JSONEncoder().encode(days)
            return data
        } catch {
            print("Ошибка при кодировании: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            print("Ошибка: данные отсутствуют или неверного типа")
            return nil
        }
        do {
            let days = try JSONDecoder().decode([Weekdays].self, from: data)
            return days
        } catch {
            print("Ошибка при декодировании: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self)))
    }
}
