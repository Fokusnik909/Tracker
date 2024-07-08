//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Артур  Арсланов on 01.07.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let completeButton = UIButton()
    private let countLabel = UILabel()
    var completionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        contentView.addSubview(titleLabel)
        contentView.addSubview(completeButton)
        contentView.addSubview(countLabel)
    }
    
    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            completeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 30),
            completeButton.heightAnchor.constraint(equalToConstant: 30),
            
            countLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -10),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int) {
        titleLabel.text = tracker.name
        completeButton.setImage(UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "plus.circle"),
                                for: .normal)
        countLabel.text = "\(completionCount)"
    }
    
    @objc private func completeButtonTapped() {
        completionHandler?()
    }
    
}
