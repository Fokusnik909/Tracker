//
//  NewHabitCell.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.07.2024.
//

import UIKit

final class NewHabitCell: UITableViewCell {
    static let newHabitCell = "NewHabitCell"
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .ypBlack
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    func configure(with text: String) {
        label.text = text
    }
}
