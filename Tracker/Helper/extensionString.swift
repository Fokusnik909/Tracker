//
//  extensionString.swift
//  Tracker
//
//  Created by Артур  Арсланов on 26.09.2024.
//

import Foundation

extension String {
    var localised: String {
        return NSLocalizedString(self, comment: "")
    }
}
