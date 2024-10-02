//
//  StatisticItemView.swift
//  Tracker
//
//  Created by Артур  Арсланов on 23.09.2024.
//

import Foundation
import UIKit

final class StatisticItemView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let gradientBorderLayer = CAShapeLayer()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    init(number: Int, text: String) {
        super.init(frame: .zero)
        numberLabel.text = String(number)
        descriptionLabel.text = text
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        
        gradientBorderLayer.path = path.cgPath
        gradientBorderLayer.frame = bounds
        
        gradientLayer.mask = gradientBorderLayer
    }
    
    func updateNumber(_ number: Int) {
        numberLabel.text = String(number)
    }

    
    private func setupView() {
        gradientLayer.colors = [
            UIColor(hex: "#007BFA").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#FD4C49").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        layer.addSublayer(gradientLayer)
        
        gradientBorderLayer.lineWidth = 2
        gradientBorderLayer.fillColor = UIColor.clear.cgColor
        gradientBorderLayer.strokeColor = UIColor.black.cgColor
        
        // Радиус закругления
        layer.cornerRadius = 16
        layer.masksToBounds = true
        gradientBorderLayer.cornerRadius = 16
        
        layer.addSublayer(gradientBorderLayer)
        
        // Настройка стека для лейблов
        let stackView = UIStackView(arrangedSubviews: [numberLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 7
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
}

