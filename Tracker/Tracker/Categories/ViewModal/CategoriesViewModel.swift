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
    //    {
    //        didSet {
    //            self.onCategoriesUpdated?(categories)
    //        }
    //    }
    
    var onCategoriesUpdated: Binding<[TrackerCategory]>?
    var selectCategory: Binding<TrackerCategory?>?
    
    init() {
        fetchCategories()
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
            onCategoriesUpdated?(categories)
        } catch {
            print("Ошибка при создании категории: \(error)")
        }
    }
    
    
}

