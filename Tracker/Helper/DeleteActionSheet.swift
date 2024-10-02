//
//  DeleteActionSheet.swift
//  Tracker
//
//  Created by Артур  Арсланов on 26.09.2024.
//

import UIKit

final class DeleteActionSheet {

    static func present(on viewController: UIViewController?, title: String?, message: String?, handler: @escaping () -> Void) {
        guard let viewController = viewController else {
            print("Не удалось представить UIAlertController, так как viewController равен nil.")
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { _ in
            handler()
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            alert.dismiss(animated: true)
        })

        viewController.present(alert, animated: true, completion: nil)
    }
}
