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

    init() {
        guard let url = Bundle.main.url(forResource: "background.mp3", withExtension: nil) else {
            print("Error: background.mp3 file not found in the project bundle.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            
            // Store the initial volume
            self.volumeBeforeMute = audioPlayer?.volume ?? 1.0
            
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio player: \(error.localizedDescription)")
        }
    }

    func play() {
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func toggleMute() {
        // This will trigger the didSet block which contains the new logic
        isMuted.toggle()
    }
}
