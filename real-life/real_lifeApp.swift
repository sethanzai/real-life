//
//  real_lifeApp.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//

import SwiftUI
import SwiftData

@main
struct real_lifeApp: App {
    @State private var isShowingSplash = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashScreenView()
                    // 3. Trigger the transition after a delay
                    .onAppear {
                        // Wait for 2.5 seconds, then hide the splash screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                            withAnimation {
                                self.isShowingSplash = false
                            }
                        }
                    }
            } else {
                // Your app's main view
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
