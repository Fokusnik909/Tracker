//
//  extensionhideKeyboard.swift
//  Tracker
//
//  Created by Артур  Арсланов on 16.07.2024.
//

import UIKit

extension UIViewController {
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
}
