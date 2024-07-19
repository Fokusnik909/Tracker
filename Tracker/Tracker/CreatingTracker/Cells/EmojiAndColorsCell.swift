//
//  EmojisAndColorsCell.swift
//  Tracker
//
//  Created by Артур  Арсланов on 18.07.2024.
//

import UIKit

final class EmojiAndColorsCell: UICollectionViewCell {
    static let identifier = "EmojiAndColors"
    
    //MARK: - Private Property
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            emojiLabel.isHidden = true
            colorView.isHidden = true
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.shadowColor = UIColor.clear.cgColor
            contentView.layer.shadowOpacity = 0
        }
    
    //MARK: - Functions
    func configure(with emoji: String, isSelected: Bool) {
            emojiLabel.text = emoji
            emojiLabel.isHidden = false
            colorView.isHidden = true
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? UIColor.ypRed.cgColor : UIColor.clear.cgColor
            contentView.layer.shadowColor = isSelected ? UIColor.ypRed.cgColor : UIColor.clear.cgColor
            contentView.layer.shadowOpacity = isSelected ? 0.8 : 0
            contentView.layer.shadowRadius = isSelected ? 4 : 0
            contentView.layer.shadowOffset = CGSize(width: 0, height: isSelected ? 4 : 0)
        }
    
    func configure(with color: UIColor, isSelected: Bool) {
            colorView.backgroundColor = color
            colorView.isHidden = false
            emojiLabel.isHidden = true
            colorView.layer.borderWidth = isSelected ? 3 : 0
            colorView.layer.borderColor = isSelected ? color.cgColor : UIColor.clear.cgColor
            contentView.layer.shadowColor = isSelected ? color.cgColor : UIColor.clear.cgColor
            contentView.layer.shadowOpacity = isSelected ? 0.8 : 0
            contentView.layer.shadowRadius = isSelected ? 4 : 0
            contentView.layer.shadowOffset = CGSize(width: 0, height: isSelected ? 4 : 0)
        }
    
    //MARK: - Private Function
    private func setupViews() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorView)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 52),
            colorView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}

