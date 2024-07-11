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
    
    private var heightTableView: CGFloat = 0
    private var selectedWeekDays: [WeekDay] = []
    private let scheduleLabel = "Расписание"
    
    //MARK: - Private properties UI
    private var customTextField: CustomTextField
    
    private lazy var cancelButton = CustomButton(title: "Отменить", titleColor: .ypRed, backgroundColor: .ypWhite, borderColor: .ypRed)
    private lazy var createButton = CustomButton(title: "Создать", titleColor: .ypWhite, backgroundColor: .ypGray)

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
        self.customTextField = .init(placeholder: "Введите название трекера")

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
        customTextField.addTarget(self, action: #selector(habitTextField), for: .editingChanged)

    }
    
    @objc private func habitTextField() {
        
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
    
    private func updateScheduleLabel() {
        guard let index = countRows.firstIndex(of: scheduleLabel) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        
        let daysString = selectedWeekDays.map { $0.shortName }.joined(separator: ", ")
        let isAllDays = selectedWeekDays.count == 7 ? "Каждый день" : daysString
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewHabitCell {
            cell.configure(with: scheduleLabel, detailText: isAllDays)
        }
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
        
        if countRows[indexPath.row] == scheduleLabel {
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedWeekDays = selectedWeekDays
            scheduleVC.didSelectWeekDays = { [weak self] selectedDays in
                self?.selectedWeekDays = selectedDays
                self?.updateScheduleLabel()
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
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
