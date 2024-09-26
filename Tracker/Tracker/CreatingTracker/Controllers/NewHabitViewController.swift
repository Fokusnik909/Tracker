//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.07.2024.
//

import UIKit

protocol NewHabitDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, category: TrackerCategory)
    func didUpdateTracker(_ tracker: Tracker, category: TrackerCategory)
}

final class NewHabitViewController: UIViewController {
    
    weak var delegate: NewHabitDelegate?
    
    var trackType: TrackType
    var countRows = [String]()
    var regularTracker: Tracker?

    //MARK: - Private Property
    private var params = GeometricParams(cellCount: 6, leftInset: 16, rightInset: 16, cellSpacing: 5)
    
    private var heightTableView: CGFloat = 0
    private var selectedWeekDays: Set<Weekdays> = []
    private let scheduleLabel = NSLocalizedString(DictionaryString.newHabitScheduleCell, comment: "")
    private let categoriesLabel = NSLocalizedString(DictionaryString.newHabitCategoryCell, comment: "")
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectCategory: String?
    
    private let allEmoji = ColorsAndEmojiCells.allEmoji
    private let allColors = ColorsAndEmojiCells.allColors
    
    //MARK: - Private properties UI
    private lazy var customTextField: CustomTextField = {
        let text = NSLocalizedString(DictionaryString.newHabitNamePlaceholder, comment: "")
        let textField = CustomTextField(placeholder: text)
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let title = NSLocalizedString(DictionaryString.newHabitCancelButton, comment: "")
        let button = CustomButton(
            title: title,
            titleColor: .ypRed,
            backgroundColor: .ypWhite,
            borderColor: .ypRed
        )
        return button
    }()
    
    
    private lazy var createButton: CustomButton = {
        let title = regularTracker != nil ? NSLocalizedString("Save", comment: "") : NSLocalizedString("Create", comment: "")
        let button = CustomButton(
            title: title,
            titleColor: .ypWhite,
            backgroundColor: .ypGray
        )
        return button
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        return collectionView
    }()
    
    private let hStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private let tableView: UITableView = .init()
    
    //MARK: - Init
    init(trackType: TrackType) {
        self.trackType = trackType

        super.init(nibName: nil, bundle: nil)

        configureRows(for: trackType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTapGestureToHideKeyboard()
        
        if let tracker = regularTracker {
            customTextField.text = tracker.name
            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
            selectedWeekDays = Set(tracker.schedule)
            updateScheduleLabel()
            updateCategoryLabel()
            validateForm()
        }
    }
    
    //MARK: - Private @objc Methods
    @objc private func habitTextField(_ textField: UITextField) {
        validateForm()
    }
    
    @objc private func createButtonPressed() {
        guard let name = customTextField.text, !name.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else { return }
        
        let tracker = Tracker(
            id: regularTracker?.id ?? UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: Array(selectedWeekDays),
            isPinned: false
        )
        
        let category = TrackerCategory(title: selectCategory ?? "Без категории", trackers: [tracker])
        
        if let _ = regularTracker {
            delegate?.didUpdateTracker(tracker, category: category)
        } else {
            delegate?.didCreateNewTracker(tracker, category: category)
        }
        
        dismiss(animated: true)
    }

    
    @objc private func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    //MARK: - Private Methods
    private func configureRows(for trackType: TrackType) {
        switch trackType {
        case .regular:
            countRows = [categoriesLabel, scheduleLabel]
            heightTableView = 150
        case .notRegular:
            countRows = [categoriesLabel]
            heightTableView = 75
        }
    }
    
    private func validateForm() {
        let isFormValid: Bool
        
        guard let text = customTextField.text, !text.isEmpty,
              selectedEmoji != nil, selectedColor != nil else {
            updateCreateButtonState(false)
            return
        }
        
        switch trackType {
        case .regular:
            isFormValid = !selectedWeekDays.isEmpty && selectCategory != nil
        case .notRegular:
            isFormValid = true
        }
        
        updateCreateButtonState(isFormValid)
    }

    
    private func updateScheduleLabel() {
        guard let index = countRows.firstIndex(of: scheduleLabel) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        
        let stringEveryday = NSLocalizedString(DictionaryString.newHabitScheduleSubtitle, comment: "")
        
        let daysString = selectedWeekDays.map { $0.shortName }.joined(separator: ", ")
        let isAllDays = selectedWeekDays.count == 7 ? stringEveryday : daysString
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewHabitCell {
            cell.configure(with: scheduleLabel, detailText: isAllDays)
        }
    }
    
    private func updateCategoryLabel() {
        guard let index = countRows.firstIndex(of: categoriesLabel) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        
        let category = selectCategory
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewHabitCell {
            cell.configure(with: categoriesLabel, detailText: category)
        }
    }
    
    private func switchingAnotherController(_ selectedСell: String) {
        if selectedСell == scheduleLabel {
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedWeekDays = selectedWeekDays
            scheduleVC.delegate = self
            let navController = UINavigationController(rootViewController: scheduleVC)
            present(navController, animated: true)
        }
        
        if selectedСell == categoriesLabel {
            let viewModel = CategoriesViewModel()
            let categoriesVC = CategoriesView(viewModal: viewModel)
            categoriesVC.delegate = self
            let navController = UINavigationController(rootViewController: categoriesVC)
            present(navController, animated: true)
        }
    }
    
    private func updateCreateButtonState(_ isValid: Bool) {
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .ypBlack : .ypGray
    }
    
}

//MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitCell.newHabitCell, for: indexPath) as? NewHabitCell else {
            return UITableViewCell()
        }
        
        let text = countRows[indexPath.row]
        if text == scheduleLabel {
            let daysString = selectedWeekDays.map { $0.shortName }.joined(separator: ", ")
            cell.configure(with: text, detailText: daysString)
        } else {
            cell.configure(with: text, detailText: selectCategory)
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

}

//MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedСell = countRows[indexPath.row]
        switchingAnotherController(selectedСell)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == countRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension NewHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = section == 0 ? allEmoji.count : allColors.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiAndColorsCell.identifier,
            for: indexPath) as? EmojiAndColorsCell
        else {
            return UICollectionViewCell()
        }
        
        
        if indexPath.section == 0 {
            let emoji = allEmoji[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
        } 
        else {
            let color = allColors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let viewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiAndColorHeader.identifier, for: indexPath) as? EmojiAndColorHeader else {
            return UICollectionReusableView()
        }
        
        let stringColor = NSLocalizedString(DictionaryString.newHabitColor, comment: "")
        
        if indexPath.section == 0 {
            viewHeader.configure("Emoji")
        } else {
            viewHeader.configure(stringColor)
        }
        return viewHeader
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let previouslySelectedEmoji = selectedEmoji
            selectedEmoji = allEmoji[indexPath.item]
            
            if let previouslySelectedEmoji = previouslySelectedEmoji,
               let previousIndex = allEmoji.firstIndex(of: previouslySelectedEmoji) {
                collectionView.reloadItems(at: [IndexPath(item: previousIndex, section: 0)])
            }
            
            collectionView.reloadItems(at: [indexPath])
            
        } else {
            let previouslySelectedColor = selectedColor
            selectedColor = allColors[indexPath.item]
            
            if let previouslySelectedColor = previouslySelectedColor,
               let previousIndex = allColors.firstIndex(of: previouslySelectedColor) {
                collectionView.reloadItems(at: [IndexPath(item: previousIndex, section: 1)])
            }
            
            collectionView.reloadItems(at: [indexPath])
        }
        
        validateForm()

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 16, left: params.leftInset, bottom: 40, right: params.rightInset)
        } else {
            return UIEdgeInsets(top: 16, left: params.leftInset, bottom: 800, right: params.rightInset)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
}

//MARK: - Setting Views
private extension NewHabitViewController {
    func setupView() {
        addSubViews()
        setupLayout()
        setupTableView()
        settingEventButton()
        setupCollectionView()
        view.backgroundColor = .ypWhite
        navigationItem.title = NSLocalizedString(DictionaryString.newHabitScreenTitle, comment: "")
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        hStack.addArrangedSubview(cancelButton)
        hStack.addArrangedSubview(createButton)
        
        contentView.addSubview(customTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(hStack)
        contentView.addSubview(emojiCollectionView)
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .ypBackground
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewHabitCell.self, forCellReuseIdentifier: NewHabitCell.newHabitCell)
    }
    
    private func setupCollectionView() {
        emojiCollectionView.register(EmojiAndColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiAndColorHeader.identifier)

        emojiCollectionView.register(EmojiAndColorsCell.self, forCellWithReuseIdentifier: EmojiAndColorsCell.identifier)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.isScrollEnabled = false
        
        
    }
    
    func settingEventButton() {
        customTextField.addTarget(self, action: #selector(habitTextField), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }
    
    func setupLayout() {
        [scrollView, contentView, customTextField, tableView, emojiCollectionView, hStack, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        //TO DO: - подумать над версткой
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            customTextField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            customTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: customTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: heightTableView),
            
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 540),
            
            
            hStack.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hStack.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
}


//MARK: - ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectWeekDays(_ selectedDays: [Weekdays]) {
        self.selectedWeekDays = Set(selectedDays)
        self.updateScheduleLabel()
        self.validateForm()
    }
    
}


extension NewHabitViewController: CategoriesViewDelegate {
    func didSelectCategory(_ category: String) {
        self.selectCategory = category
        updateCategoryLabel()
        validateForm()
    }
}
