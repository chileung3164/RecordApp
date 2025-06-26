import Foundation
import AVFoundation

// MARK: - Audio Service
class AudioService: AudioServiceProtocol {
    private var audioPlayer: AVAudioPlayer?
    
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "buzzer", withExtension: "wav") else {
            print("Could not find buzzer.wav file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    func playSound() {
        audioPlayer?.play()
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
} 