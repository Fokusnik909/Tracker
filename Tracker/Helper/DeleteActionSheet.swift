//
//  DeleteActionSheet.swift
//  Tracker
//
//  Created by Артур  Арсланов on 26.09.2024.
//

import UIKit

final class DeleteActionSheet {
    private let alert: UIAlertController
    
    init(title: String?, message: String?, handler: @escaping () -> Void) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: ""), style: .destructive) { _ in
            handler()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel) { action in
            self.alert.dismiss(animated: true)
        })
    }
    
    func present(_ viewController: UIViewController?) {
        guard let viewController = viewController else {
            print("Не удалось представить UIAlertController, так как viewController равен nil.")
            return
        }
        viewController.present(alert, animated: true, completion: nil)
    }
}
