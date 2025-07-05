//
//  ContentView.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//

import SwiftUI
import SwiftData

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = DataStore()
    @State private var selectedCard: (String, Category)? = nil
    @State private var showCard = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("The Real Life")
                    .font(.custom("Quicksand-Bold", size: 48))
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if !showCard {
                    CategoryGridView(categories: dataStore.categories, selectedCard: $selectedCard, showCard: $showCard)
                }

                if let selectedCard = selectedCard, showCard {
                    FlashCardView(categoryName: selectedCard.0, category: selectedCard.1, showCard: $showCard)
                }
            }
            .padding(20)
        }
    }
}

struct CategoryGridView: View {
    let categories: [String: Category]
    @Binding var selectedCard: (String, Category)?
    @Binding var showCard: Bool

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
            ForEach(categories.keys.sorted(), id: \.self) { key in
                if let category = categories[key] {
                    Button(action: {
                        self.selectedCard = (key, category)
                        self.showCard = true
                    }) {
                        Text(key)
                            .font(.custom("Quicksand-Bold", size: 20))
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: category.color))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
