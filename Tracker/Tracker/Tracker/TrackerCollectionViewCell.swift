//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Артур  Арсланов on 01.07.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(tracker: Tracker, isCompleted: Bool)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var tracker: Tracker?
    private var isComplete = false
    private var calendarDate = Date()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "addButton"), for: .normal)
        button.tintColor = .ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        return button
    }()
    
    //    Или в данной ситуации лучше было использовать замыкание вместо делагатов?
    
    //    var completionHandler: ((Tracker, Bool)->Void)?
    //MARK: - Init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let sizeButton = CGFloat(34)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            daysLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            completeButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            completeButton.widthAnchor.constraint(equalToConstant: sizeButton),
            completeButton.heightAnchor.constraint(equalToConstant: sizeButton)
        ])
        completeButton.layer.cornerRadius = sizeButton / 2
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int, calendar: Date) {
        self.isComplete = isCompleted
        self.calendarDate = calendar
        self.tracker = tracker

        completeButton.isSelected = isCompleted
        isSelectedButton(completeButton, trackerColor: tracker.color)

        emojiLabel.text = tracker.emoji
        emojiLabel.backgroundColor = tracker.color.withAlphaComponent(0.3)
        
        titleLabel.text = tracker.name
        containerView.backgroundColor = tracker.color
        
        let tasksString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "Number of remaining tasks"),
            completionCount
        )
        
        daysLabel.text = tasksString
    }
    
    private func isSelectedButton(_ sender: UIButton, trackerColor: UIColor) {
        if sender.isSelected {
            sender.setImage(UIImage(named: "done"), for: .normal)
            sender.tintColor = trackerColor
            sender.layer.opacity = 0.3
        } else {
            sender.setImage(UIImage(named: "addButton"), for: .normal)
            sender.tintColor = .ypWhite
            sender.backgroundColor = trackerColor
            sender.layer.opacity = 1
        }
    }
    
    @objc private func completeButtonTapped(_ sender: UIButton) {
        guard calendarDate <= Date() else { return }

        guard let tracker else { return }

        completeButton.isSelected.toggle()

        isSelectedButton(sender, trackerColor: tracker.color)

        delegate?.didTapCompleteButton(tracker: tracker, isCompleted: sender.isSelected)
    }
}
