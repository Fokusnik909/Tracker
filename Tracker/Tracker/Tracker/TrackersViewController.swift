//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    //MARK: - Private properties
    private var params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    
    private lazy var trackerManager: TrackerManagerProtocol? = {
        let store = TrackerStore()
        do {
            return try TrackerStoreManager(store, delegate: self)
        } catch {
            print("Не удалось инициализировать trackerManager: \(error)")
            return nil
        }
    }()
    
    private lazy var trackerCategoryManager: TrackerCategoryManagerProtocol? = {
       let store = TrackerCategoryStore()
        do {
            return try TrackerCategoryStoreManager(trackerCategoryStore: store, delegate: self)
        } catch {
            print("Не удалось инициализировать TrackerCategoryDataProvider: \(error)")
            return nil
        }
    }()
    
    private lazy var trackerRecordManager: TrackerRecordManagerProtocol? = {
        let store = TrackerRecordStore()
        do {
            return try TrackerRecordDataManager(trackerRecordStore: store, delegate: self)
        } catch {
            print("Не удалось инициализировать TrackerRecordDataProvider: \(error)")
            return nil
        }
    }()
    
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
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_DE")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
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
        fetchData()
        addTapGestureToHideKeyboard()
        
    }
    
    //MARK: - Private Methods
    private func fetchData() {
        do {
            categories = trackerCategoryManager?.fetchCategories() ?? []
            completedTrackers = try trackerRecordManager?.fetch() ?? []
            updateVisibleCategories()
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }
    
    @objc private func addButton() {
        let newTrackerViewController = NewCreateTrackerViewController()
        newTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {
        visibleCategories = getVisibleCategories()
        updateEmptyState()
        collectionView.reloadData()
    }
    
    private func updateEmptyState() {
        let isEmpty = visibleCategories.isEmpty
        imageStar.isHidden = !isEmpty
        logoLabel.isHidden = !isEmpty
    }
    
    private func getVisibleCategories() -> [TrackerCategory] {
        guard let currentDayOfWeek = Weekdays.from(date: currentDate) else {
            return []
        }
        
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let shouldDisplay = tracker.schedule.isEmpty || tracker.schedule.contains(currentDayOfWeek)
                return shouldDisplay
            }

            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addBarButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
    }
    
    private func layout() {
        view.backgroundColor = .white
        
        for view in subView {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        //TO DO: - подумать над версткой 
        
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
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        let isComplete = completedTrackers.contains { $0.id == tracker.id && $0.date == currentDate }
        let counter = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configure(with: tracker, isCompleted: isComplete, completionCount: counter, calendar: currentDate)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let viewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as? TrackerHeader else {
            return UICollectionReusableView()
        }
        
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionTitle = visibleCategories[indexPath.section].title
            viewHeader.configure(sectionTitle)
            return viewHeader
        }
        return viewHeader
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    //Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
}

//MARK: - NewCreateTrackerDelegate
extension TrackersViewController: NewHabitDelegate {
    func didCreateNewTracker(_ tracker: Tracker, category: TrackerCategory) {
        do {
            try trackerManager?.addTracker(tracker, category: category)
            fetchData()
        } catch {
            print(#function, error)
        }
        updateVisibleCategories()
        collectionView.reloadData()
        
    }
}

//MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(tracker: Tracker, isCompleted: Bool) {
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
        if isCompleted {
            do {
                try trackerRecordManager?.add(trackerRecord: trackerRecord)
                completedTrackers.append(trackerRecord)
            } catch {
                print("Ошибка при добавлении завершенного трекера: \(error)")
            }
        } else {
            do {
                try trackerRecordManager?.delete(trackerRecord: trackerRecord)
                completedTrackers.removeAll { $0.id == tracker.id && $0.date == currentDate }
            } catch {
                print("Ошибка при удалении завершенного трекера: \(error)")
            }
        }
        
        updateCellForTracker(tracker)
        updateVisibleCategories()
    }
    
    private func updateCellForTracker(_ tracker: Tracker) {

        for section in 0..<visibleCategories.count {
            if let row = visibleCategories[section].trackers.firstIndex(where: { $0.id == tracker.id }) {
                let indexPath = IndexPath(row: row, section: section)
                collectionView.reloadItems(at: [indexPath])
                break
            }
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: update.insertedIndexes.map { IndexPath(item: $0, section: 0) })
            collectionView.deleteItems(at: update.deletedIndexes.map { IndexPath(item: $0, section: 0) })
        }, completion: nil)
        
    }
}

extension TrackersViewController: TrackerCategoryManagerDelegate {
    func didUpdate(_ update: TrackerCategoryUpdate) {
        fetchData()
    }
    
}

extension TrackersViewController: TrackerRecordManagerDelegate {
    func didUpdate(_ update: TrackerRecordStoreUpdate) {
        fetchData()
    }

}

