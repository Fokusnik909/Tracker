//
//  CustomTextField.swift
//  Tracker
//
//  Created by Артур  Арсланов on 08.07.2024.
//

import UIKit

final class CustomTextField: UITextField {
    //MARK: - Private Property
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    //MARK: - Init
    init(placeholder: String) {
        super.init(frame: .zero)
        setupTextField(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override Methods
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    //MARK: - Private Methods
    private func setupTextField(placeholder: String) {
        textColor = .ypBlack
        layer.cornerRadius = 16
        layer.backgroundColor = UIColor.ypBackground.cgColor
        
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray])
        
        font = .systemFont(ofSize: 17)
        heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
}
