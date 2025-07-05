//
//  DataStore.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//
import Foundation

class DataStore: ObservableObject {
    @Published var categories: [String: Category] = [:]

    init() {
        loadData()
    }

    func loadData() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            fatalError("Failed to locate questions.json in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load questions.json from bundle.")
        }

        let decoder = JSONDecoder()

        guard let loadedCategories = try? decoder.decode([String: Category].self, from: data) else {
            fatalError("Failed to decode questions.json from bundle.")
        }

        self.categories = loadedCategories
    }
}
