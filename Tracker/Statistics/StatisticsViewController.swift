//
//  Statistics.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private lazy var stubStatisticsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stubStatistics")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: .init(12), weight: .semibold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(stubStatisticsImageView)
        view.addSubview(stubLabel)
        
        stubStatisticsImageView.translatesAutoresizingMaskIntoConstraints = false
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stubStatisticsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStatisticsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubStatisticsImageView.bottomAnchor, constant: 8)
        ])
        
    }
}

