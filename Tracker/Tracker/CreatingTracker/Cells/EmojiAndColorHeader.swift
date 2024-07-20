//
//  EmojiAndColorHeader.swift
//  Tracker
//
//  Created by Артур  Арсланов on 19.07.2024.
//

import UIKit

final class EmojiAndColorHeader: UICollectionReusableView {
    
    static let identifier = "EmojiAndColorHeader"
    
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.text = "Домашний уют"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(headerLabel)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 28),
            headerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
       
    }
    
    func configure(_ header: String) {
        headerLabel.text = header
    }
}
