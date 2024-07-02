//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

public protocol TrackerViewProtocol {
    var presenter: TrackerPresenterProtocol? { get set }
}

final class TrackerView: UIViewController, TrackerViewProtocol {
    
    var presenter: TrackerPresenterProtocol?
    
    //MARK: - Private properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var addBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "addButton"),
            style: .plain,
            target: self,
            action: #selector(addButton)
        )
        button.tintColor = .black
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
       let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
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
    
    lazy private var subView: [UIView] = [self.collectionView, self.imageStar, self.logoLabel]
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupNavigationBar()
    }
    
    //MARK: - Private Methods
    @objc private func addButton() {
        print(#function)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    private func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        if let index = categories.firstIndex(where: {$0.title == title}) {
            var category = categories[index]
            var trackers = category.trackers
            trackers.append(tracker)
            category = TrackerCategory(title: category.title, trackers: trackers)
        } else {
            let newCategory = TrackerCategory(title: title, trackers: [tracker])
            categories.append(newCategory)
        }
    }
    
    private func markTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        let record = TrackerRecord(id: tracker.id, date: date)
        completedTrackers.append(record)
    }
    
    private func unmarkTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        if let index = completedTrackers.firstIndex(where: {$0.id == tracker.id && $0.date == date}) {
            completedTrackers.remove(at: index)
        }
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addBarButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        
    }
    
    private func setupCollectionView() {
        collectionView.register(TrackerView.self, forCellWithReuseIdentifier: "cell")
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
