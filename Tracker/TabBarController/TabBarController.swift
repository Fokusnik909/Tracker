//
//  TabBarController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
    private func config() {
        separationLine()
                
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackerBar"),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticsBar"),
            selectedImage: nil
        )
        
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false
        
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
    
    private func separationLine() {
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        tabBar.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                separatorView.topAnchor.constraint(equalTo: tabBar.topAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
}

