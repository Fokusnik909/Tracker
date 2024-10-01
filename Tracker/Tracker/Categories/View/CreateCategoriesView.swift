//
//  CreateCategoriesView.swift
//  Tracker
//
//  Created by Артур  Арсланов on 13.09.2024.
//

import UIKit

protocol CreateCategoriesViewDelegate: AnyObject {
    func didSelectCategory(_ category : String)
}

final class CreateCategoriesView: UIViewController {

    //MARK: - Delegate
    weak var delegate: CreateCategoriesViewDelegate?
    
    private let viewModel: CategoriesViewModel
    
    private var customTextField: CustomTextField = {
        let text = NSLocalizedString(DictionaryString.newCategoryNamePlaceholder, comment: "")
        let textField = CustomTextField(placeholder: text)
        return textField
    }()
    
    private lazy var createButton: CustomButton = {
        let titleButton = NSLocalizedString(DictionaryString.buttonDone, comment: "")
        let button = CustomButton(
            title: titleButton,
            titleColor: .ypWhite,
            backgroundColor: .ypGray
        )
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTextField.addTarget(self, action: #selector(habitTextField), for: .editingChanged)
        setupUI()
        addTapGestureToHideKeyboard()
    }
    
    @objc private func habitTextField(_ textField: UITextField) {
        validateForm()
    }
    
    @objc private func createButtonTapped() {
        guard let title = customTextField.text, !title.isEmpty else { return }
        
        if viewModel.categories.contains(where: { $0.title == title }) {
            showDuplicateCategoryAlert()
            return
        }
        
        delegate?.didSelectCategory(title)
        viewModel.onCategoryCreated?(title)
        dismiss(animated: true)
    }
    
    private func showDuplicateCategoryAlert() {
        let alert = UIAlertController(
            title: "oops".localised,
            message: "categoryExists".localised,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "ok".localised, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func validateForm() {
        let isFormValid = !(customTextField.text?.isEmpty ?? true)
        updateCreateButtonState(isFormValid)
    }
    
    private func updateCreateButtonState(_ isValid: Bool) {
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .ypBlack : .ypGray
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubview(customTextField)
        view.addSubview(createButton)
        customTextField.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        title = NSLocalizedString(DictionaryString.newCategoryScreenTitle, comment: "")
        
        NSLayoutConstraint.activate([
            customTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            customTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
