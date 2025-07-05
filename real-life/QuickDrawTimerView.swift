//
//  QuickDrawTimerView.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//

import SwiftUI

struct QuickDrawTimerView: View {
    @Binding var timeLeft: Int
    @Binding var isTimerRunning: Bool
    @Binding var flash: Bool
    let startTimer: () -> Void
    let resetTimer: () -> Void

    var body: some View {
        VStack {
            Text(timeLeft > 0 ? "\(timeLeft)" : "⏰ Time's up!")
                .font(.custom("Quicksand-Bold", size: 48))
                .fontWeight(.bold)
                .foregroundColor(flash ? .red : .green)
                .shadow(color: .green, radius: 10)
                .padding()

            HStack(spacing: 20) {
                Button("Start", action: startTimer)
                    .disabled(isTimerRunning)
                Button("Reset", action: resetTimer)
            }
            .font(.custom("Quicksand-SemiBold", size: 20))
            .foregroundColor(.white)
        }
        .padding()
    }
}

#Preview {
    QuickDrawTimerView(
        timeLeft: .constant(40),
        isTimerRunning: .constant(false),
        flash: .constant(false),
        startTimer: {},
        resetTimer: {}
    )
    .previewDisplayName("Initial State")
}
