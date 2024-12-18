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
    private var searchText: String = ""
    private var currentDate: Date = Date()
    private var pinnedTrackersCategory: TrackerCategory?
    
    private var currentFilter: TrackerFilter = .allTrackers

    
    private lazy var trackerRecordStore = TrackerRecordStore()
    private var trackerManager: TrackerManagerProtocol?
    private var trackerCategoryManager: TrackerCategoryManagerProtocol?
    private var trackerRecordManager: TrackerRecordManagerProtocol?
    
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
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.backgroundColor = .ypPickerColor
        datePicker.preferredDatePickerStyle = .compact
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
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
        label.text = NSLocalizedString(DictionaryString.mainScreenTitle, comment: "")
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    lazy private var subView: [UIView] = [self.collectionView, self.imageStar, self.logoLabel]
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeManagers()
        loadFilter()
        setupUIComponents()
        fetchData()
        addTapGestureToHideKeyboard()
        AnalyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    
    //MARK: - Private Methods
    private func fetchData() {
        do {
            categories = trackerCategoryManager?.fetchCategories() ?? []
            completedTrackers = try trackerRecordManager?.fetch() ?? []
            print("Completed trackers: \(completedTrackers)")
            updateVisibleCategories()
            collectionView.reloadData()
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }
    
    private func initializeManagers() {
        do {
            trackerManager = try TrackerStoreManager(TrackerStore(), delegate: self)
            trackerCategoryManager = try TrackerCategoryStoreManager(trackerCategoryStore: TrackerCategoryStore(), delegate: self)
            trackerRecordManager = try TrackerRecordDataManager(trackerRecordStore: TrackerRecordStore(), delegate: self)
        } catch {
            print("Ошибка инициализации: \(error)")
        }
    }
    
    private func setupUIComponents() {
        layout()
        setupFilterButton()
        setupNavigationBar()
        setupCollectionView()
    }
    
    @objc private func addButton() {
        AnalyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        let newTrackerViewController = NewCreateTrackerViewController()
        newTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func didTapFilterButton() {
        let filterVC = FilterOptionsViewController()
        filterVC.currentFilter = currentFilter
        filterVC.filterSelectionHandler = { [weak self] selectedFilter in
            self?.applyFilter(selectedFilter)
        }
        let navVC = UINavigationController(rootViewController: filterVC)
        AnalyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        present(navVC, animated: true)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        saveFilter()
        
        if currentFilter == .todayTrackers {
            currentDate = Date()
            datePicker.date = currentDate
        }
        
        updateVisibleCategories()
        filterButton.setTitleColor(currentFilter == .allTrackers ? .white : .ypRed, for: .normal)
    }
    
    private func loadFilter() {
        if let savedFilter = UserDefaults.standard.string(forKey: "currentFilter"),
           let filter = TrackerFilter(rawValue: savedFilter) {
            currentFilter = filter
        }
    }
    
    private func saveFilter() {
        UserDefaults.standard.set(currentFilter.rawValue, forKey: "currentFilter")
    }
    
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {
        visibleCategories = getVisibleCategories()
        updateEmptyState()
        filterButton.isHidden = visibleCategories.isEmpty
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
        
        let pinnedTrackers = categories
            .flatMap { $0.trackers }
            .filter { $0.isPinned }
        
        if !pinnedTrackers.isEmpty {
            pinnedTrackersCategory = TrackerCategory(title: "mainPinnedCategory".localised, trackers: pinnedTrackers)
        } else {
            pinnedTrackersCategory = nil
        }
        
        let filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let isScheduledForToday = tracker.schedule.isEmpty || tracker.schedule.contains(currentDayOfWeek)
                let matchesSearchText = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                
                switch currentFilter {
                case .allTrackers:
                    return isScheduledForToday && matchesSearchText && !tracker.isPinned
                case .todayTrackers:
                    return isScheduledForToday && matchesSearchText && Calendar.current.isDate(currentDate, inSameDayAs: Date()) && !tracker.isPinned
                case .completedTrackers:
                    return isScheduledForToday && matchesSearchText && isTrackerCompleted(id: tracker.id) && !tracker.isPinned
                case .uncompletedTrackers:
                    return isScheduledForToday && matchesSearchText && !isTrackerCompleted(id: tracker.id) && !tracker.isPinned
                }
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        if let pinnedCategory = pinnedTrackersCategory {
            return [pinnedCategory] + filteredCategories
        } else {
            return filteredCategories
        }
    }
    
    
    //MARK: - setupNavigationBar
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addBarButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = NSLocalizedString(DictionaryString.mainScreenLabel, comment: "")
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.ypBlack]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString(DictionaryString.mainScreenSearchPlaceholder, comment: "")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    
    //MARK: - setupCollectionView
    private func setupCollectionView() {
        collectionView.backgroundColor = .ypWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
    }
    
    private func layout() {
        view.backgroundColor = .ypWhite
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
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
    
    func isTrackerCompleted(id: UUID) -> Bool {
        return trackerRecordStore.isTrackerCompleted(id: id, date: currentDate)
    }
    
    private func setupFilterButton() {
        filterButton.setTitle("filters".localised, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        filterButton.setTitleColor(.ypWhite, for: .normal)
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        filterButton.backgroundColor = .ypBlue
        filterButton.layer.cornerRadius = 16
        
        
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else {
            return 0
        }
        return visibleCategories[section].trackers.count
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
        
        let isComplete = isTrackerCompleted(id: tracker.id)
        let isPinned = tracker.isPinned
        let counter = completedTrackers.filter { $0.id == tracker.id }.count

        cell.configure(with: tracker, isCompleted: isComplete, completionCount: counter, calendar: currentDate, isPinned: isPinned)
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
    func didUpdateTracker(_ tracker: Tracker, category: TrackerCategory) {
        print("полученная категория \(category.title)")
        do {
            try trackerManager?.updateTracker(tracker, category: category.title)
            fetchData()
            collectionView.reloadData()
        } catch {
            print(#function, error)
        }
        updateVisibleCategories()
    }
    
    
    func didCreateNewTracker(_ tracker: Tracker, category: TrackerCategory) {
        do {
            try trackerManager?.addTracker(tracker, category: category)
            fetchData()
            collectionView.reloadData()
        } catch {
            print(#function, error)
        }
        updateVisibleCategories()
        
    }
    
}

//MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(tracker: Tracker, isCompleted: Bool) {
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
        guard currentDate <= Date() else {
            print("Невозможно завершить трекер для будущей даты.")
            return
        }

        if isCompleted {
            guard !completedTrackers.contains(where: { $0.id == tracker.id && $0.date == currentDate }) else {
                return
            }
            do {
                try trackerRecordManager?.add(trackerRecord: trackerRecord)
                completedTrackers.append(trackerRecord)
            } catch {
                print("Ошибка при добавлении завершенного трекера: \(error)")
            }
        } else {
            do {
                try trackerRecordManager?.delete(id: tracker.id, date: currentDate)
                completedTrackers.removeAll { $0.id == tracker.id && $0.date == currentDate }
            } catch {
                print("Ошибка при удалении завершенного трекера: \(error)")
            }
        }
        AnalyticsService.report(event: "click", params: ["screen": "Main", "item": "track"])
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


// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPath.section < visibleCategories.count,
              indexPath.row < visibleCategories[indexPath.section].trackers.count else {
            return nil
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let menuItems: [UIAction] = [
            UIAction(title: tracker.isPinned ? "unpin".localised : "pin".localised, image: nil) { [weak self] _ in
                self?.togglePin(for: tracker)
            },
            UIAction(title: "edit".localised, image: nil) { [weak self] _ in
                self?.editTracker(tracker, at: indexPath)
            },
            
            UIAction(title: "delete".localised, image: nil, attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                DeleteActionSheet.present(
                    on: self,
                    title: nil,
                    message: "SureDeleteTracker".localised,
                    handler: { [weak self] in
                        self?.deleteTracker(tracker)
                    }
                )
            }
        ]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            return UIMenu(title: "", children: menuItems)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        UIView.animate(withDuration: 0.5) {
            if offsetY > 0 {
                self.filterButton.alpha = 0.0
            } else {
                self.filterButton.alpha = 1.0
            }
        }
    }

    private func togglePin(for tracker: Tracker) {
        do {
            try trackerManager?.togglePin(for: tracker)
            fetchData()
            updateVisibleCategories()
            collectionView.reloadData()
        } catch {
            print("Ошибка при переключении закрепления трекера: \(error)")
        }
    }
    
    private func editTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let category = visibleCategories[indexPath.section]
        let editHabitVC = NewHabitViewController(trackType: .regular)
        editHabitVC.regularTracker = tracker
        editHabitVC.editTrackerCategory = category
        editHabitVC.delegate = self
        AnalyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        present(editHabitVC, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        
        
        do {
            try trackerManager?.deleteTracker(tracker)
            fetchData()
            collectionView.reloadData()
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
        AnalyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        updateVisibleCategories()
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }

        let param = UIPreviewParameters()
        param.visiblePath = UIBezierPath(roundedRect: cell.getContainerViewBounds(), cornerRadius: 16)

        return UITargetedPreview(view: cell, parameters: param)
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        return UITargetedPreview(view: cell)
    }

}

//MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        updateVisibleCategories()
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.reloadData()
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

