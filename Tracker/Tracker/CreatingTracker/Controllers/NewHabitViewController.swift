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
    
    //MARK: - Private properties UI
    private let cancelButton: UIButton = {
       let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypGray
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
        
        switch trackType {
        case .regular:
            countRows = ["Категория", "Расписание"]
        case .notRegular:
            countRows = ["Категория"]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        
        tableView.dataSource = self
        
        navigationItem.title = "Новая привычка"
        navigationItem.setHidesBackButton(true, animated: true)
        tableView.register(NewHabitCell.self, forCellReuseIdentifier: NewHabitCell.newHabitCell)
    }
    
    private func layout() {
        view.backgroundColor = .ypWhite
        view.addSubview(hStack)
        view.addSubview(tableView)
        hStack.addArrangedSubview(cancelButton)
        hStack.addArrangedSubview(createButton)
        
        [hStack, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            hStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitCell.newHabitCell, for: indexPath) as? NewHabitCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0 :
            cell.textLabel?.text = "Kaтегория"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Расписаниее"
            cell.accessoryType = .disclosureIndicator
        default : break
        }
        
        return cell
    }
    
    
}
