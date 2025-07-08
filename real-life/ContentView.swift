//
//  ContentView.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var dataStore = DataStore()
    @StateObject private var audioManager = AudioManager()
    @State private var selectedCard: (String, Category)? = nil
    @State private var showCard = false

    var body: some View {
        GeometryReader { gr in
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
                
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            audioManager.toggleMute()
                        }) {
                            Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.title2)
                                .padding(gr.size.width/10)
                                .background(.black.opacity(0.6))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .frame(width: gr.size.width, height: gr.size.height)
            }
            .onAppear {
                audioManager.play()
            }
            .onChange(of: showCard) { _, isShowing in
                isShowing ? audioManager.pause() : audioManager.play()
            }
        }
    }
}

struct CategoryGridView: View {
    let categories: [String: Category]
    @Binding var selectedCard: (String, Category)?
    @Binding var showCard: Bool

    // 1. Read the horizontalSizeClass from the environment.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // 2. Create computed properties that adapt to the size class.
    private var gridColumns: [GridItem] {
        let gridSpacing: CGFloat = 15
        // Use a larger minimum item size for iPads (.regular)
        let minimumItemSize: CGFloat = horizontalSizeClass == .regular ? 240 : 140
        return [GridItem(.adaptive(minimum: minimumItemSize), spacing: gridSpacing)]
    }

    private var buttonFontSize: CGFloat {
        return horizontalSizeClass == .regular ? 26 : 20
    }

    private var buttonMinHeight: CGFloat {
        return horizontalSizeClass == .regular ? 120 : 80
    }

    var body: some View {
        // 3. Use the adaptive properties in your layout.
        LazyVGrid(columns: gridColumns, spacing: 15) {
            ForEach(categories.keys.sorted(), id: \.self) { key in
                if let category = categories[key] {
                    Button(action: {
                        self.selectedCard = (key, category)
                        self.showCard = true
                    }) {
                        Text(key)
                            .font(.custom("Quicksand-Bold", size: buttonFontSize))
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: buttonMinHeight)
                            .background(Color(hex: category.color))
                            .foregroundColor(.white)
                            .cornerRadius(12) // Slightly larger radius for bigger buttons
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
