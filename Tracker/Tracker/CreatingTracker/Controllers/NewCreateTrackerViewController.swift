//
//  NewCreateTracker.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.07.2024.
//

import UIKit

protocol NewCreateTrackerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, category: String)
}

final class NewCreateTrackerViewController: UIViewController {
    weak var delegate: NewHabitDelegate?
    
    //MARK: - Private properties UI
    private let habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(nil, action: #selector(habitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let notRegularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярные событие", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(nil, action: #selector(notRegularEventButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 16
        stack.axis = .vertical
        return stack
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Создание трекера"
        layout()
    }
    
    //MARK: - Private Methods
    private func layout() {
        view.backgroundColor = .ypWhite
        view.addSubview(vStackView)
        vStackView.addArrangedSubview(habitButton)
        vStackView.addArrangedSubview(notRegularEventButton)
            
        [vStackView, habitButton, notRegularEventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            notRegularEventButton.heightAnchor.constraint(equalToConstant: 60),
            
            vStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
    }
    
    
    //MARK: - Event methods
    @objc private func habitButtonPressed() {
        let newHabit = NewHabitViewController(trackType: .regular)
        newHabit.delegate = delegate
        navigationController?.pushViewController(newHabit, animated: true)
    }
    
    @objc private func notRegularEventButtonPressed() {
        let newHabit = NewHabitViewController(trackType: .notRegular)
        newHabit.delegate = delegate
        navigationController?.pushViewController(newHabit, animated: true)
    }
}

//MARK: - NewHabitDelegate
//extension NewCreateTrackerViewController: NewHabitDelegate {
//    func didCreateNewHabit(_ tracker: Tracker, category: String) {
//        delegate?.didCreateNewTracker(tracker, category: category)
//    }

