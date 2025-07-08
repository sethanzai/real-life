//
//  SplashScreenView.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/08.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // Use a ZStack to place the image as a background
            Image("SplashBackground") // The name you set in Assets.xcassets
                .resizable()         // Makes the image resizable
                .scaledToFill()      // Scales the image to fill the entire screen
                .ignoresSafeArea()   // Makes the image extend into the safe areas (like the notch)
        }
    }
}

#Preview {
    SplashScreenView()
}
