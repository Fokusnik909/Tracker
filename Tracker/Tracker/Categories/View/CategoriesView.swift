//
//  View.swift
//  Tracker
//
//  Created by Артур  Арсланов on 12.09.2024.
//

import UIKit

final class CategoriesView: UIViewController {
    
    private let viewModal: CategoriesViewModel
    private let tableView: UITableView = .init()
    private var heightTableView: CGFloat = 0
    private var categoriesCount = 0
    private var selectedCategory: IndexPath?
    
    private lazy var createButton: CustomButton = {
        let button = CustomButton(
            title: "Добавить категорию",
            titleColor: .ypWhite,
            backgroundColor: .ypBlack
        )
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let imageStar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MainStar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let labelStub: UILabel = {
        let label = UILabel()
        label.text = """
                        Привычки и события можно
                        объединить по смыслу
                        """
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModal: CategoriesViewModel) {
        self.viewModal = viewModal
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupUI()
        isEmptyCategory()
    }
    
    @objc private func createButtonTapped() {
        let newCategoryViewController = CreateCategoriesView(viewModel: viewModal)
        let navController = UINavigationController(rootViewController: newCategoryViewController)
        present(navController, animated: true)
    }

    
    private func bindViewModel() {
        
        viewModal.onCategoriesUpdated = { [weak self] categories in
            guard let self else { return }
            self.categoriesCount = categories.count
            self.tableView.reloadData()
            self.isEmptyCategory()
        }
        
        viewModal.fetchCategories()
        
    }
    
    private func isEmptyCategory() {
        let isEmpty = categoriesCount == 0
        imageStar.isHidden = !isEmpty
        labelStub.isHidden = !isEmpty
    }
    
    private func setupUI() {
        view.addSubview(imageStar)
        view.addSubview(createButton)
        view.addSubview(labelStub)
        view.addSubview(tableView)
        view.backgroundColor = .ypWhite
        
        setupTableView()
        
        navigationItem.hidesBackButton = true
        title = "Категория"
        NSLayoutConstraint.activate([
            imageStar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 232),
            imageStar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStar.widthAnchor.constraint(equalToConstant: 80),
            imageStar.heightAnchor.constraint(equalToConstant: 80),
            
            labelStub.topAnchor.constraint(equalTo: imageStar.bottomAnchor, constant: 8),
            labelStub.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelStub.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(categoriesCount * 75))
        ])
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .red
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoriesViewCell.self, forCellReuseIdentifier: "CategoryCell")
    }
}


extension CategoriesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoriesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesViewCell.categoryCell, for: indexPath) as? CategoriesViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModal.categories[indexPath.row]
        cell.configure(with: category.title, isSelected: selectedCategory == indexPath)
        return cell
    }
    
    
}

extension CategoriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModal.selectCategory(at: indexPath.row)
        selectedCategory = indexPath
        tableView.reloadData()
        self.dismiss(animated: true)
    }
}
