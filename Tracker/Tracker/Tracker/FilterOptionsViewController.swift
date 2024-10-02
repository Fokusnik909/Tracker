//
//  FilterOptionsViewController.swift
//  Tracker
//
//  Created by Артур  Арсланов on 26.09.2024.
//

import Foundation
import UIKit

enum TrackerFilter: String {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completedTrackers = "Завершённые"
    case uncompletedTrackers = "Незавершённые"
}

final class FilterOptionsViewController: UIViewController {
    
    var currentFilter: TrackerFilter = .allTrackers
    var filterSelectionHandler: ((TrackerFilter) -> Void)?
    private let filterTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()
    
    private let filters: [TrackerFilter] = [.allTrackers, .todayTrackers, .completedTrackers, .uncompletedTrackers]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        title = "filers".localised
        
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterTableView)
        
        NSLayoutConstraint.activate([
            filterTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterСell")
        filterTableView.backgroundColor = .ypWhite
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension FilterOptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterСell", for: indexPath)
        let filter = filters[indexPath.row]
        
        cell.textLabel?.text = filter.rawValue
        cell.textLabel?.textColor = .ypBlack
        cell.accessoryType = (filter == currentFilter) ? .checkmark : .none
        cell.backgroundColor = .ypBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        filterSelectionHandler?(selectedFilter)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
