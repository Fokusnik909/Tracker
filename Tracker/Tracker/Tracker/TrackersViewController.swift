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
        // MOCK DATA
        createMockData()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("UpdateTrackersEvent"), object: nil)
    }
    
    //MARK: - Private Methods
    @objc private func addButton() {
        let newTrackerViewController = NewCreateTrackerViewController()
        newTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        currentDate = sender.date
        updateVisibleCategories()
        collectionView.reloadData()
    }
    
    private func updateVisibleCategories() {
        visibleCategories = getVisibleCategories()
        if visibleCategories.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }

    private func showEmptyState() {
        imageStar.isHidden = false
        logoLabel.isHidden = false
    }

    private func hideEmptyState() {
        imageStar.isHidden = true
        logoLabel.isHidden = true
    }
    
    private func getVisibleCategories() -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        if let currentDayOfWeek = Weekdays.from(date: currentDate) {
            for category in categories {
                var trackers: [Tracker] = []
                for tracker in category.trackers {
                    if tracker.schedule.contains(currentDayOfWeek) {
                        trackers.append(tracker)
                    }
                }
                if !trackers.isEmpty {
                    result.append(TrackerCategory(title: category.title, trackers: trackers))
                }
            }
        }
        
        return result
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
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
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
        
        cell.delegate = self
        
        let trackerCategory = visibleCategories[indexPath.section]
        let tracker = trackerCategory.trackers[indexPath.row]
        let counter = completedTrackers.filter { $0.id == tracker.id }.count
        let isComplete = completedTrackers.filter { $0.id == tracker.id && $0.date == currentDate }.count > 0
        
        cell.configure(with: tracker, isCompleted: isComplete, completionCount: counter, calendar: currentDate)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let viewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as? TrackerHeader else {
            return UICollectionReusableView()
        }
        
        if kind == UICollectionView.elementKindSectionHeader {
            let trackerCategory = visibleCategories[indexPath.section]
            viewHeader.configure(trackerCategory.title)
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
    func didCreateNewTracker(_ tracker: Tracker, category: String) {

        // Находим индекс категории
        if let index = categories.firstIndex(where: { $0.title == category }) {
            // Обновляем категорию с добавленным трекером
            let updatedCategory = categories[index]
            var updatedTrackers = updatedCategory.trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(title: updatedCategory.title, trackers: updatedTrackers)
        } else {
            // Если категории не существует, создаем новую
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            categories.append(newCategory)
        }
        
        updateVisibleCategories()
        collectionView.reloadData()
        
    }
}

//MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(tracker: Tracker, isCompleted: Bool) {
        if isCompleted {
            let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
            completedTrackers.append(trackerRecord)
        } else {
            completedTrackers.removeAll { $0.id == tracker.id && $0.date == currentDate }
        }
        
        updateCellForTracker(tracker)
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



extension TrackersViewController {
    func createMockData() {
        let plantWatering = Tracker(
            id: UUID(),
            name: "Поливать растения",
            color: UIColor.systemGreen, emoji: "❤️",
            schedule: Weekdays.allCases
        )
        
        let cat = Tracker(
            id: UUID(),
            name: "Кошка заслонила камеру на созвоне",
            color: UIColor.orange,
            emoji: "😻",
            schedule: Weekdays.allCases
        )
        
        let whatsApp = Tracker(
            id: UUID(),
            name: "Бабушка прислала открытку в вотсапе",
            color: UIColor.red,
            emoji: "🌺",
            schedule: Weekdays.allCases
        )
        
        let aprilDraw = Tracker(
            id: UUID(),
            name: "Свидания в апреле",
            color: UIColor.blue,
            emoji: "❤️",
            schedule: Weekdays.allCases
        )
        
        let homeComfort = TrackerCategory(title: "Домашний уют", trackers: [plantWatering])
        let joyfulLittleThings = TrackerCategory(title: "Радостные мелочи", trackers: [cat, whatsApp, aprilDraw])
        
        categories = [homeComfort, joyfulLittleThings]
        updateVisibleCategories()
    }
}
