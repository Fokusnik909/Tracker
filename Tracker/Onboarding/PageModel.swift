//
//  PageModel.swift
//  Tracker
//
//  Created by Артур  Арсланов on 19.09.2024.
//

import Foundation
import UIKit

enum PageModel {
    case firstPage
    case secondPage

    var image: UIImage {
        switch self {
        case .firstPage:
            return UIImage(named: "page_1") ?? UIImage()
        case .secondPage:
            return UIImage(named: "page_2") ?? UIImage()
        }
    }

    var text: String {
        switch self {
        case .firstPage:
            return NSLocalizedString(DictionaryString.onboardingScreenFirstTitle, comment: "")
        case .secondPage:
            return NSLocalizedString(DictionaryString.onboardingScreenSecondTitle, comment: "")
        }
    }
}
