//
//  View.swift
//  Tracker
//
//  Created by Артур  Арсланов on 12.09.2024.
//

import UIKit

protocol CategoriesViewDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoriesView: UIViewController {
    
    //MARK: - Delegate
    weak var delegate: CategoriesViewDelegate?
    
    //MARK: - Private Property
    private let viewModal: CategoriesViewModel
    private var selectedCategory: IndexPath?
    private var selectedCategoryTitle: String?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()
    
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
    
    //MARK: - Init
    init(viewModal: CategoriesViewModel) {
        self.viewModal = viewModal
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
        isEmptyCategory()
    }
    
    //MARK: - Private @objc Methods
    @objc private func createButtonTapped() {
        let newCategoryViewController = CreateCategoriesView(viewModel: viewModal)
        newCategoryViewController.delegate = self
        let navController = UINavigationController(rootViewController: newCategoryViewController)
        present(navController, animated: true)
    }
    
    //MARK: - Private Methods
    private func bindViewModel() {
        viewModal.onCategoryCreated = { [weak self] category in
            guard let self = self else { return }
            viewModal.addCategory(category)
            self.tableView.reloadData()
        }
        
        viewModal.onCategoriesUpdated = { [weak self] categories in
            guard let self else { return }
            self.tableView.reloadData()
            self.isEmptyCategory()
        }
        
        viewModal.fetchCategories()
    }
    
    private func isEmptyCategory() {
        let isEmpty = viewModal.categories.isEmpty
        imageStar.isHidden = !isEmpty
        labelStub.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    //MARK: - SetupUI
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -47)
        ])
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoriesViewCell.self, forCellReuseIdentifier: "CategoryCell")
    }
}

//MARK: - UITableViewDataSource
extension CategoriesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModal.categories.count
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

//MARK: - UITableViewDelegate
extension CategoriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModal.categories[indexPath.row].title
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModal.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

//MARK: - CreateCategoriesViewDelegate
extension CategoriesView: CreateCategoriesViewDelegate {
    func didSelectCategory(_ category: String) {
        tableView.reloadData()
        isEmptyCategory()
    }
}