//
//  TabBarController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    let separatorViewColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark {
            return .ypWhite
        } else {
            return .ypLightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
    private func config() {
        separationLine()
                
        let trackerViewController = TrackersViewController()
        let navVCMain = UINavigationController(rootViewController: trackerViewController)
        navVCMain.tabBarItem = UITabBarItem(
            title: NSLocalizedString(DictionaryString.tabBarFirstTab, comment: ""),
            image: UIImage(named: "TrackerBar"),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        let navVCStatistics = UINavigationController(rootViewController: statisticsViewController)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(DictionaryString.tabBarSecondTab, comment: ""),
            image: UIImage(named: "StatisticsBar"),
            selectedImage: nil
        )
        
        tabBar.backgroundColor = .ypWhite
        tabBar.isTranslucent = false
        
        self.viewControllers = [navVCMain, navVCStatistics]
    }
    
    private func separationLine() {
        let separatorView = UIView()
        separatorView.backgroundColor = separatorViewColor
        
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

