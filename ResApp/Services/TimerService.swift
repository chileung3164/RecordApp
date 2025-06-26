import Foundation
import Combine

// MARK: - Timer Service
class TimerService: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var roscTime: TimeInterval = 0
    @Published var cprCounter: Int = 0
    @Published var cprCycleCounter: Int = 0
    
    private var stopwatchTimer: Timer?
    private var roscTimer: Timer?
    private var cprTimer: Timer?
    
    func startStopwatch() {
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }
    
    func stopStopwatch() {
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil
    }
    
    func resetStopwatch() {
        elapsedTime = 0
    }
    
    func startROSCTimer() {
        roscTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.roscTime += 1
        }
    }
    
    func stopROSCTimer() {
        roscTimer?.invalidate()
        roscTimer = nil
    }
    
    func startCPRTimer(duration: TimeInterval = 120, onUpdate: @escaping (Int) -> Void, onComplete: @escaping () -> Void) {
        cprCounter = 0
        cprTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.cprCounter += 1
            onUpdate(self.cprCounter)
            
            if self.cprCounter >= Int(duration) {
                timer.invalidate()
                self.cprTimer = nil
                onComplete()
            }
        }
    }
    
    func stopCPRTimer() {
        cprTimer?.invalidate()
        cprTimer = nil
    }
    
    func stopAllTimers() {
        stopStopwatch()
        stopROSCTimer()
        stopCPRTimer()
    }
    
    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedROSCTime: String {
        let minutes = Int(roscTime) / 60
        let seconds = Int(roscTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 