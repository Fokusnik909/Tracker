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
        label.text = NSLocalizedString(DictionaryString.statisticsStubLabel, comment: "")
        label.font = .systemFont(ofSize: .init(12), weight: .semibold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private var stackView = UIStackView()
    
    private var completedTrackers: Int {
        return getCount()
    }
    
    private var completedTrackersView: StatisticItemView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        let completedTrackersLabel = NSLocalizedString(DictionaryString.statisticsCompletedTrackers, comment: "")
        completedTrackersView = StatisticItemView(number: completedTrackers, text: completedTrackersLabel)
        setupUI()
        print(getCount())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBestPeriodView()
        showStatisticsOrStub()
    }
    
    private func updateBestPeriodView() {
        completedTrackersView?.updateNumber(completedTrackers)
        completedTrackersView?.setNeedsLayout()
    }
    
    private func getCount() -> Int {
        return UserDefaults.standard.integer(forKey: "completedTrackers")
    }
    
    private func showStatisticsOrStub() {
        let hasStatistics = completedTrackers > 0
        stubLabel.isHidden = hasStatistics
        stubStatisticsImageView.isHidden = hasStatistics
        stackView.isHidden = !hasStatistics
    }
    
    private func setupUI() {
        setupStackView()
        view.addSubview(stubStatisticsImageView)
        view.addSubview(stubLabel)
        view.addSubview(stackView)
        
        title = NSLocalizedString(DictionaryString.statisticsTitle, comment: "")
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.ypBlack]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupConstraints()
    }
    
    private func setupStackView() {
        stackView = UIStackView(arrangedSubviews: [completedTrackersView].compactMap { $0 })
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
    }
    
    private func setupConstraints() {
        [stubStatisticsImageView, stubLabel, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            stubStatisticsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStatisticsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubStatisticsImageView.bottomAnchor, constant: 8),
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

}
