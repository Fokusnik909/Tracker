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
        self.delegate = self
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
        clearButtonMode = .always
    }
}


//MARK: - UITextFieldDelegate
extension CustomTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}
