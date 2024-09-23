//
//  ViewModal.swift
//  Tracker
//
//  Created by Артур  Арсланов on 12.09.2024.
//

import Foundation

typealias Binding<T> = (T) -> Void


class CategoriesViewModel {
    private var trackerCategoryStore = TrackerCategoryStore()
    
    var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?
    
    var onCategoriesUpdated: Binding<[TrackerCategory]>?
    var selectCategory: Binding<TrackerCategory?>?
    var onCategoryCreated: ((String) -> Void)?
    
    init() {
        fetchCategories()
        
        onCategoryCreated = { [weak self] categoryTitle in
            guard let self = self else { return }
            self.addCategory(categoryTitle)
        }
    }
    
    func fetchCategories() {
        categories = trackerCategoryStore.fetchAllCategories()
        onCategoriesUpdated?(categories)
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        selectCategory?(selectedCategory)
    }
    
    func addCategory(_ category: String) {
        do {
            try trackerCategoryStore.createCategory(TrackerCategory(title: category, trackers: []))
            fetchCategories()
        } catch {
            print("Ошибка при создании категории: \(error)")
        }
    }
}

