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
    
    // ✅ MODIFIED: The logic now calculates minutes and seconds.
    var formattedTime: String {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        // The format string now uses minutes and seconds.
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack {
            Text(timeLeft > 0 ? "\(formattedTime)" : "⏰ Time's up!")
                .font(.custom("Quicksand-Bold", size: 48))
                .fontWeight(.bold)
                .foregroundColor(flash ? .red : .green)
                .shadow(color: .green, radius: 10)
                .padding()

            HStack(spacing: 20) {
                Button("Start", action: startTimer)
                    .disabled(isTimerRunning)
                    .buttonStyle(RoundTimerButtonStyle(color: .green, lineColor: .green))

                Button("Reset", action: resetTimer)
                    .buttonStyle(RoundTimerButtonStyle(color: .gray, lineColor: .purple))

            }
            .font(.custom("Quicksand-SemiBold", size: 20))
            .foregroundColor(.white)
        }
        .padding()
    }
}

struct RoundTimerButtonStyle: ButtonStyle {
    let color: Color
    let lineColor: Color

    // Access the isEnabled environment variable
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 80, height: 80)
            .background(color.opacity(0.4))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(lineColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            // ✅ Apply effects based on the isEnabled state
            .saturation(isEnabled ? 1.0 : 0.2) // Desaturate when disabled
            .opacity(isEnabled ? 1.0 : 0.5)   // Make it more transparent when disabled
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
}
