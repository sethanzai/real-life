import SwiftUI
import AVFoundation // Required for audio playback
import Combine // Required for Timer.publish().sink and AnyCancellable

// MARK: - QuickDrawTimerView
// This view displays the time, the title, and the control buttons.
struct QuickDrawTimerView: View {
    @Binding var timeLeft: Int // The remaining time in seconds
    @Binding var isTimerRunning: Bool // Indicates if the timer is active
    @Binding var flashColor: Bool // Controls the flashing color effect
    let startTimer: () -> Void // Closure to start the timer
    let resetTimer: () -> Void // Closure to reset the timer

    // Helper to format time into MM:SS
    private var formattedTime: String {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack {
            // Title of the stopwatch
            Text("Countdown Stopwatch")
                .font(.system(size: 28, weight: .bold)) // Adjust font to match image
                .foregroundColor(.white)
                .padding(.bottom, 40) // Add padding below the title

            // Display the formatted time or "Time's up!" message
            Text(timeLeft > 0 ? formattedTime : "⏰ Time's up!")
                .font(.system(size: 80, weight: .bold)) // Larger font for time
                .fontWeight(.bold)
                // Dynamically change text color based on flashColor and timeLeft
                .foregroundColor(flashColor ? .red : (timeLeft > 0 ? Color(red: 0.5, green: 0.9, blue: 0.5) : .blue)) // Greenish color from image
                // Add a shadow that changes color based on flashColor
                .shadow(color: flashColor ? .orange : Color(red: 0.5, green: 0.9, blue: 0.5).opacity(0.7), radius: 10)
                .padding(.bottom, 60) // Padding below the time
                .animation(.easeInOut(duration: 0.5), value: flashColor) // Smooth animation for color change

            // HStack for the control buttons
            HStack(spacing: 40) { // Increased spacing between buttons
                // Start Button
                Button(action: startTimer) {
                    Text("Start")
                        .font(.system(size: 24, weight: .medium)) // Font size for buttons
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120) // Square button size
                        .background(Color.clear) // Transparent background
                        .overlay(
                            RoundedRectangle(cornerRadius: 10) // Slightly rounded corners for the border
                                .stroke(Color(red: 0.5, green: 0.9, blue: 0.5), lineWidth: 4) // Green border
                        )
                        .opacity(isTimerRunning || timeLeft == 0 ? 0.5 : 1.0) // Dim if disabled
                }
                .disabled(isTimerRunning || timeLeft == 0) // Disable if running or time is up

                // Reset Button
                Button(action: resetTimer) {
                    Text("Reset")
                        .font(.system(size: 24, weight: .medium)) // Font size for buttons
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120) // Square button size
                        .background(Color.clear) // Transparent background
                        .overlay(
                            RoundedRectangle(cornerRadius: 10) // Slightly rounded corners for the border
                                .stroke(Color(red: 0.4, green: 0.4, blue: 0.8), lineWidth: 4) // Blue/purple border
                        )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the VStack take full available space
        .background(Color(red: 0.15, green: 0.17, blue: 0.2)) // Dark background color from image
        .edgesIgnoringSafeArea(.all) // Extend background to safe areas
    }
}

// MARK: - CountdownStopwatchView (Main Container View)
// This view manages the state and logic for the timer.
struct CountdownStopwatchView: View {
    @State private var timeLeft: Int = 40 // Initial countdown time
    @State private var isTimerRunning: Bool = false // State to control timer activity
    @State private var flashColor: Bool = false // State to control the flashing effect
    @State private var timerSubscription: AnyCancellable? // Holds the timer subscription
    @State private var countdownPlayer: AVAudioPlayer? // Audio player for countdown sound
    @State private var timesUpPlayer: AVAudioPlayer? // Audio player for "Time's up!" sound

    // Constants for sound file names
    private let countdownSoundFileName = "countdown" // Make sure you have countdown.mp3 in your project
    private let timesUpSoundFileName = "timesup"     // Make sure you have timesup.mp3 in your project

    var body: some View {
        QuickDrawTimerView(
            timeLeft: $timeLeft,
            isTimerRunning: $isTimerRunning,
            flashColor: $flashColor,
            startTimer: startTimer,
            resetTimer: resetTimer
        )
        .onAppear(perform: setupAudioPlayers) // Setup audio when the view appears
        .onDisappear(perform: stopAllSounds) // Stop sounds when the view disappears
    }

    // MARK: - Timer Logic

    // Function to start the countdown timer
    private func startTimer() {
        // Ensure the timer is not already running and time is left
        guard !isTimerRunning && timeLeft > 0 else { return }

        isTimerRunning = true
        flashColor = false // Reset flash when starting

        // Play countdown sound
        countdownPlayer?.play()

        // Create and subscribe to a new timer publisher
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect() // Automatically connect the publisher
            .sink { _ in // Sink to receive events from the timer
                if timeLeft > 0 {
                    timeLeft -= 1 // Decrement time
                    // Toggle flashColor for visual effect when 10 seconds or less remain
                    if timeLeft <= 10 {
                        flashColor.toggle()
                    }
                } else {
                    // Timer has reached zero
                    stopTimer() // Stop the timer
                    isTimerRunning = false // Update running state
                    flashColor = false // Ensure flash is off at the end
                    timesUpPlayer?.play() // Play "Time's up!" sound
                    countdownPlayer?.stop() // Stop countdown sound if it's still playing
                    countdownPlayer?.currentTime = 0 // Reset countdown sound to beginning
                }
            }
    }

    // Function to stop the timer
    private func stopTimer() {
        timerSubscription?.cancel() // Cancel the timer subscription
        timerSubscription = nil // Release the subscription
    }

    // Function to reset the timer to its initial state
    private func resetTimer() {
        stopTimer() // Stop any active timer
        isTimerRunning = false // Set timer state to not running
        timeLeft = 40 // Reset time to 40 seconds
        flashColor = false // Reset flash color state
        stopAllSounds() // Stop all sounds
    }

    // MARK: - Audio Logic

    // Sets up the audio players for countdown and "time's up" sounds
    private func setupAudioPlayers() {
        // Load countdown sound
        if let soundURL = Bundle.main.url(forResource: countdownSoundFileName, withExtension: "mp3") {
            do {
                countdownPlayer = try AVAudioPlayer(contentsOf: soundURL)
                countdownPlayer?.numberOfLoops = -1 // Loop indefinitely for countdown
                countdownPlayer?.volume = 0.5 // Set volume
            } catch {
                print("Could not load \(countdownSoundFileName).mp3: \(error.localizedDescription)")
            }
        } else {
            print("Could not find \(countdownSoundFileName).mp3 in bundle.")
        }

        // Load "time's up" sound
        if let soundURL = Bundle.main.url(forResource: timesUpSoundFileName, withExtension: "mp3") {
            do {
                timesUpPlayer = try AVAudioPlayer(contentsOf: soundURL)
                timesUpPlayer?.volume = 0.8 // Set volume
            } catch {
                print("Could not load \(timesUpSoundFileName).mp3: \(error.localizedDescription)")
            }
        } else {
            print("Could not find \(timesUpSoundFileName).mp3 in bundle.")
        }
    }

    // Stops all currently playing sounds and resets their playback position
    private func stopAllSounds() {
        countdownPlayer?.stop()
        countdownPlayer?.currentTime = 0 // Reset to beginning
        timesUpPlayer?.stop()
        timesUpPlayer?.currentTime = 0 // Reset to beginning
    }
}

// MARK: - Preview Provider
// Provides a preview of the CountdownStopwatchView in Xcode's canvas.
struct CountdownStopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownStopwatchView()
    }
}
