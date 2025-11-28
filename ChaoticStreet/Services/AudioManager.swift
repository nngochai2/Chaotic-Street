/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
    Nguyen Ngoc Hai, S3978281
    Nguyen Huy Hoang, S4041847
    Bui Minh Duc, S4070921
  Created date: 16/09/2025
  Last modified: 16/09/2025
  Acknowledgement: Fixed to support multiple simultaneous audio players
*/

import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    // FIXED: Multiple players instead of single player
    private var players: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private init() {
        // Configure audio session for better audio handling
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // FIXED: Separate method for background music
    func playBackgroundMusic(named soundName: String, volume: Double = 1.0) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("Could not find background music file: \(soundName)")
            return
        }
        
        do {
            // Stop existing background music if any
            backgroundMusicPlayer?.stop()
            
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = Float(volume)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            
            print("Background music started: \(soundName)")
        } catch {
            print("Error playing background music \(soundName): \(error.localizedDescription)")
        }
    }
    
    // FIXED: Sound effects don't interfere with background music
    func playSound(named soundName: String, volume: Double = 1.0, loop: Bool = false) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("Could not find sound file: \(soundName)")
            return
        }
        
        do {
            // Create or reuse player for this sound
            if players[soundName] == nil {
                players[soundName] = try AVAudioPlayer(contentsOf: url)
                players[soundName]?.prepareToPlay()
            }
            
            // Configure and play the sound
            players[soundName]?.volume = Float(volume)
            players[soundName]?.numberOfLoops = loop ? -1 : 0
            players[soundName]?.stop() // Stop if already playing
            players[soundName]?.currentTime = 0 // Reset to beginning
            players[soundName]?.play()
            
        } catch {
            print("Error playing sound \(soundName): \(error.localizedDescription)")
        }
    }
    
    // FIXED: Separate controls for different audio types
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        print("Background music stopped")
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        print("Background music paused")
    }
    
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
        print("Background music resumed")
    }
    
    func stopSound(named soundName: String) {
        players[soundName]?.stop()
    }
    
    func stop() {
        // Stop background music
        backgroundMusicPlayer?.stop()
        
        // Stop all sound effects
        players.values.forEach { $0.stop() }
        print("All audio stopped")
    }
    
    // FIXED: Separate volume controls
    func setBackgroundMusicVolume(_ volume: Double) {
        backgroundMusicPlayer?.volume = Float(volume)
    }
    
    func setSoundEffectVolume(_ volume: Double, for soundName: String) {
        players[soundName]?.volume = Float(volume)
    }
    
    func setVolume(_ volume: Double) {
        // Set volume for background music
        backgroundMusicPlayer?.volume = Float(volume)
        
        // Set volume for all sound effects
        players.values.forEach { $0.volume = Float(volume) }
    }
    
    // ADDITIONAL: Check if background music is playing
    func isBackgroundMusicPlaying() -> Bool {
        return backgroundMusicPlayer?.isPlaying ?? false
    }
    
    // ADDITIONAL: Cleanup method
    func cleanup() {
        backgroundMusicPlayer?.stop()
        players.values.forEach { $0.stop() }
        players.removeAll()
        backgroundMusicPlayer = nil
    }
}
