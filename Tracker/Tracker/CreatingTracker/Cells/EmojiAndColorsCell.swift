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
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var colorSelectedBorder: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "selectColor")
        image.isHidden = true
        return image
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
    }
    
    //MARK: - Functions
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        emojiLabel.isHidden = false
        colorView.isHidden = true
        emojiLabel.backgroundColor = isSelected ? .ypLightGray : .clear
        emojiLabel.layer.cornerRadius = 16
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        colorSelectedBorder.tintColor = color
        colorSelectedBorder.isHidden = !isSelected
    }
    
    //MARK: - Private Function
    private func setupViews() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorView)
        contentView.addSubview(colorSelectedBorder)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorSelectedBorder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 52),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: frame.width - 12),
            colorView.heightAnchor.constraint(equalToConstant: frame.height - 12),
            
            colorSelectedBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorSelectedBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorSelectedBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorSelectedBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
