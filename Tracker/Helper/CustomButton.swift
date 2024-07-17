//
//  CusomButton.swift
//  Tracker
//
//  Created by Артур  Арсланов on 10.07.2024.
//

import UIKit

class CustomButton: UIButton {
    
    init(
        title: String,
        titleColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor? = nil,
        cornerRadius: CGFloat = 16,
        fontSize: CGFloat = 16,
        fontWeight: UIFont.Weight = .medium
    ) {
        super.init(frame: .zero)
        setupButton(
            title: title,
            titleColor: titleColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            fontSize: fontSize,
            fontWeight: fontWeight
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(
        title: String,
        titleColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor? = nil,
        cornerRadius: CGFloat,
        fontSize: CGFloat,
        fontWeight: UIFont.Weight
    ) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        layer.cornerRadius = cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
        
        
        if let borderColor = borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        }
    }
}
