//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.07.2024.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    var trackType: TrackType
    var countRows = [String]()
    var regularTracker: Tracker?
    
    private var trackerService = TrackerService.shared
    private var heightTableView: CGFloat = 0
    private var selectedWeekDays: [Weekdays] = []
    private let scheduleLabel = "Расписание"
    
    var category: String = ""
    
    //MARK: - Private properties UI
    private var customTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Введите название трекера")
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = CustomButton(
            title: "Отменить",
            titleColor: .ypRed,
            backgroundColor: .ypWhite,
            borderColor: .ypRed
        )
        return button
    }()
    
    
    private lazy var createButton: CustomButton = {
        let button = CustomButton(
            title: "Создать",
            titleColor: .ypWhite,
            backgroundColor: .ypGray
        )
        return button
    }()
    
    private let hStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
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
    }
    
    @objc private func habitTextField(_ textField: UITextField) {
        validateForm()
    }
    
    @objc private func createButtonPressed() {
        guard let name = customTextField.text, !name.isEmpty else { return }
        
        
        
        let emoji = Emojis.randomEmoji()
        let color = UIColor.red
        
        let tracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, schedule: selectedWeekDays)
        trackerService.append(tracker)
        NotificationCenter.default.post(name: Notification.Name("UpdateTrackersEvent"), object: nil, userInfo: nil)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    //MARK: - Private Methods
    private func configureRows(for trackType: TrackType) {
        switch trackType {
        case .regular:
            countRows = ["Категория", "Расписание"]
            heightTableView = 150
        case .notRegular:
            countRows = ["Категория"]
            heightTableView = 75
        }
    }
    
    private func validateForm(){
        let isFormValid: Bool
        
        switch trackType {
        case .regular:
            isFormValid = customTextField.text != "" && !selectedWeekDays.isEmpty
        case .notRegular:
            isFormValid = customTextField.text != ""
        }
        
        updateCreateButtonState(isFormValid)
    }
    
    private func updateScheduleLabel() {
        guard let index = countRows.firstIndex(of: scheduleLabel) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        
        let daysString = selectedWeekDays.map { $0.shortName }.joined(separator: ", ")
        let isAllDays = selectedWeekDays.count == 7 ? "Каждый день" : daysString
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewHabitCell {
            cell.configure(with: scheduleLabel, detailText: isAllDays)
        }
    }
    
    private func switchingAnotherController(_ selectedСell: String) {
        if selectedСell == scheduleLabel {
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedWeekDays = selectedWeekDays
            scheduleVC.didSelectWeekDays = { [weak self] selectedDays in
                guard let self else { return }
                self.selectedWeekDays = selectedDays
                self.updateScheduleLabel()
                self.validateForm()
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
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
            cell.configure(with: text)
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

//MARK: - Setting Views
private extension NewHabitViewController {
    func setupView() {
        addSubViews()
        setupLayout()
        setupTableView()
        settingEventButton()
        view.backgroundColor = .ypWhite
        navigationItem.title = "Новая привычка"
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func addSubViews() {
        view.addSubview(customTextField)
        view.addSubview(tableView)
        view.addSubview(hStack)
        hStack.addArrangedSubview(cancelButton)
        hStack.addArrangedSubview(createButton)
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
    
    func settingEventButton() {
        customTextField.addTarget(self, action: #selector(habitTextField), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }
    
    func setupLayout() {
        [customTextField, tableView, hStack, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            customTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            customTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: customTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: heightTableView),
            
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            hStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
