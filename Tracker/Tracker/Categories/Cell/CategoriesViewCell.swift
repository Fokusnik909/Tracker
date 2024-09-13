//
//  CategoriesViewCell.swift
//  Tracker
//
//  Created by Артур  Арсланов on 13.09.2024.
//

import UIKit

final class CategoriesViewCell: UITableViewCell {
    static let categoryCell = "CategoryCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .ypBackground
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ])
    }
    
    func configure(with text: String, isSelected: Bool = true) {
        label.text = text
        accessoryType = isSelected ? .checkmark : .none
    }
}
