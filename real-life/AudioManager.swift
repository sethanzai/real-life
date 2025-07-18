//
//  AudioManager.swift
//  real-life
//
//  Created by Shu Anzai on 2025/07/05.
//
import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    // This property will store the volume level before muting.
    private var volumeBeforeMute: Float = 1.0
    
    // Published property to update the mute button UI
    @Published var isMuted = false {
        didSet {
            if isMuted {
                // Before muting, store the current volume if it's not already 0
                if audioPlayer?.volume ?? 0 > 0 {
                    volumeBeforeMute = audioPlayer?.volume ?? 1.0
                }
                // Set volume to 0 to mute
                audioPlayer?.volume = 0
            } else {
                // Restore the volume to its previous level to unmute
                audioPlayer?.volume = volumeBeforeMute
            }
        }
    }
    
    // **MODIFICATION**: Add an initializer to configure the audio session.
    // This is the most efficient place to set up the audio session,
    // as it only needs to be done once when the AudioManager is created.
    init() {
        configureAudioSession()
    }
    
    // **MODIFICATION**: New function to set the audio session category.
    private func configureAudioSession() {
        do {
            // Set the audio session category to .playback.
            // This allows your app's audio to play even when the device is in silent mode.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }

    func play(musicFileName: String, loop: Bool = false) {
        guard let url = Bundle.main.url(forResource: musicFileName, withExtension: nil) else {
            print("Error: \(musicFileName) file not found in the project bundle.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if loop {
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            }
            
            // Restore mute state if necessary
            if isMuted {
                audioPlayer?.volume = 0
            }
            
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error loading audio player: \(error.localizedDescription)")
        }
    }

    func pause() {
        audioPlayer?.pause()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil // Release the player instance
    }

    func toggleMute() {
        // This will trigger the didSet block which contains the new logic
        isMuted.toggle()
    }
}
