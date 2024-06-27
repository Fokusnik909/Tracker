//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import Foundation
import UIKit

final class TrackerViewController: UIViewController {
    
    private let imageStar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MainStar")
        return imageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy private var subView: [UIView] = [self.imageStar, self.logoLabel]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        view.backgroundColor = .white
        for view in subView {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            logoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -220),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageStar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStar.bottomAnchor.constraint(equalTo: logoLabel.topAnchor, constant: -8),
            imageStar.widthAnchor.constraint(equalToConstant: 80),
            imageStar.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
