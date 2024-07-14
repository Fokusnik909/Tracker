//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    //MARK: - Private properties
    private var params = GeometricParams(cellCount: 2, leftInset: 10, rightInset: 10, cellSpacing: 10)
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = [
        TrackerCategory(title: "Домащний уют", trackers: [Tracker(id: UUID(), name: "Поливать растения", color: .green, emoji: "❤️", schedule: [.friday, .monday, .wednesday] )] ),
        TrackerCategory(title: "Радостные мелочи", trackers: [Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .orange, emoji: "😻", schedule: [.friday]),
                                                              Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .red, emoji: "🌺", schedule: [.monday]),
                                                              Tracker(id: UUID(), name: "Свидания в апреле", color: .blue, emoji: "❤️", schedule: [.sunday])
                                                             ])
    ]
    
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
        setupCollectionView()
    }
    
    //MARK: - Private Methods
    @objc private func addButton() {
        let newTrackerViewController = NewCreateTrackerViewController()
        let navigationController = UINavigationController(rootViewController: newTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
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
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
    }
    
    private func layout() {
        view.backgroundColor = .white
        
        for view in subView {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        if visibleCategories.isEmpty {
            imageStar.isHidden = false
            logoLabel.isHidden = false
        } else {
            imageStar.isHidden = true
            logoLabel.isHidden = true
        }
        
        NSLayoutConstraint.activate([
            logoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -220),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageStar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStar.bottomAnchor.constraint(equalTo: logoLabel.topAnchor, constant: -8),
            imageStar.widthAnchor.constraint(equalToConstant: 80),
            imageStar.heightAnchor.constraint(equalToConstant: 80),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackerCategory = visibleCategories[section]
        return trackerCategory.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let trackerCategory = visibleCategories[indexPath.section]
        let tracker = trackerCategory.trackers[indexPath.row]
        
        cell.configure(with: tracker, isCompleted: false, completionCount: 5)
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth * 2 / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}
