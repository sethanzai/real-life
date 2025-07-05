//
//  FlashCardView.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//

import SwiftUI

struct FlashCardView: View {
    let categoryName: String
    let category: Category
    @Binding var showCard: Bool

    @State private var flipped = false
    @State private var question: Question?

    // Timer state
    @State private var timeLeft = 40
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    @State private var flash = false

    var isFlipCategory: Bool {
        categoryName == "Bible Trivia" || categoryName == "Who Am I"
    }

    var body: some View {
        VStack {
            ZStack {
                CardSide(text: question?.q ?? question?.text ?? "", color: Color(hex: category.color))
                    .opacity(flipped ? 0 : 1)

                CardSide(text: question?.a ?? "", color: Color(hex: category.color))
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(flipped ? 1 : 0)
            }
            .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                if isFlipCategory {
                    withAnimation(.spring()) {
                        flipped.toggle()
                    }
                }
            }
            .onAppear(perform: showRandomQuestion)

            if categoryName == "Draw" {
                QuickDrawTimerView(timeLeft: $timeLeft, isTimerRunning: $isTimerRunning, flash: $flash, startTimer: startTimer, resetTimer: resetTimer)
            }

            Button("New Question") {
                showRandomQuestion()
                flipped = false
                if categoryName == "Quick Draw" {
                    resetTimer()
                }
            }
            .padding()

            Button("Back to Categories") {
                showCard = false
                timer?.invalidate()
            }
            .padding()
        }
    }

    private func showRandomQuestion() {
        self.question = category.questions.randomElement()
    }

    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                if self.timeLeft <= 5 {
                    self.flash.toggle()
                }
            } else {
                self.timer?.invalidate()
                self.isTimerRunning = false
                self.flash = false
            }
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        isTimerRunning = false
        timeLeft = 40
        flash = false
    }
}

struct CardSide: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.custom("Quicksand-SemiBold", size: 32))
            .padding(40)
            .frame(maxWidth: 700, minHeight: 200)
            .background(Color(red: 0.06, green: 0.06, blue: 0.06))
            .foregroundColor(color)
            .cornerRadius(20)
            .shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: 2)
            )
    }
}

#Preview {
    FlashCardView(categoryName: "assadf", category: Category(label: "red", color: "red", questions: []), showCard: .constant(true))
}
