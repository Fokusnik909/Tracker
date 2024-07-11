//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 09.07.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private var weekDays = WeekDay.allCases.map { WeekDayModel(day: $0, isSelected: false)}
    
    private var trackerService: TrackerService?
    var didSelectWeekDays: ( ([WeekDay]) -> Void)?
    var selectedWeekDays: [WeekDay] = [] {
        didSet {
            for (index, weekDay) in weekDays.enumerated() {
                weekDays[index].isSelected = selectedWeekDays.contains(weekDay.day)
            }
        }
    }
    
    private let tableView: UITableView = .init()
    private let doneButton = CustomButton(title: "Готово", titleColor: .ypWhite, backgroundColor: .ypBlack)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        doneButton.addTarget(nil, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    @objc func doneButtonTapped() {
        let selectedDays = weekDays.filter { $0.isSelected }.map { $0.day }
        didSelectWeekDays?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    

}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        let weekDay = weekDays[indexPath.row]
        cell.configure(with: weekDay)
        cell.switchChanged = { [weak self] isOn in
            self?.weekDays[indexPath.row].isSelected = isOn
        }
        print(weekDays)
        print("--------------")
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension ScheduleViewController {
    func setupView() {
        view.backgroundColor = .ypWhite
        setupTableView()
        setupNavigationBar()
        layout()
    }
    
    func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .ypBackground
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Расписание"
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func layout() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(weekDays.count) * 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}
