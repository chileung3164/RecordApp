import SwiftUI

class ResuscitationManager: ObservableObject, ResuscitationManagerProtocol {
    @Published var isResuscitationStarted = false
    @Published var events: [ResuscitationEvent] = []
    @Published var resuscitationStartTime: Date?
    @Published var shouldShowAttentionEffect = false
    @Published var currentSessionID = UUID()
    
    // Time offset for fast-forward functionality (in seconds)
    @Published var timeOffset: TimeInterval = 0
    
    // Track the last real time when offset was updated (for proper time calculation)
    private var lastRealTimeUpdate: Date?
    
    // Add this line to create an instance of SmartResuscitationGuidelineSystem
    @Published var guidelineSystem = SmartResuscitationGuidelineSystem()

        
    func startResuscitation() {
            isResuscitationStarted = true
            resuscitationStartTime = Date()
            timeOffset = 0
            lastRealTimeUpdate = Date()
            events = []
            currentSessionID = UUID()
            
            // Now we can directly access guidelineSystem
            guidelineSystem.resetGuideline()
    }
    
    func endResuscitation() {
            isResuscitationStarted = false
            events = []
            resuscitationStartTime = nil
            timeOffset = 0
            lastRealTimeUpdate = nil
            guidelineSystem.stopGuideline() // Add this line to stop the guideline system
        }

    func performDefibrillation() {
        events.append(ResuscitationEvent(type: .shockDelivered(200), timestamp: getCurrentTimestamp()))
        triggerAttentionEffect()
    }

    func recordECGRhythm(_ rhythm: String) {
        events.append(ResuscitationEvent(type: .checkRhythm(rhythm), timestamp: getCurrentTimestamp()))
        if rhythm == "VF" || rhythm == "VT" {
            triggerAttentionEffect()
        }
    }

    func administarMedication(_ medication: String) {
        events.append(ResuscitationEvent(type: .medication(medication), timestamp: getCurrentTimestamp()))
        if medication == "Epinephrine" {
            triggerAttentionEffect()
        }
    }

    // Get current adjusted timestamp (accounting for fast-forward)
    func getCurrentTimestamp() -> Date {
        guard let startTime = resuscitationStartTime else { return Date() }
        let currentElapsed = getElapsedTime()
        return startTime.addingTimeInterval(currentElapsed)
    }
    
    // Get elapsed time since resuscitation started (accounting for fast-forward)
    func getElapsedTime() -> TimeInterval {
        guard let _ = resuscitationStartTime,
              let lastUpdate = lastRealTimeUpdate else { return 0 }
        
        // Calculate real elapsed time since last offset update
        let realElapsedSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
        
        // Total elapsed = offset (from fast forwards) + real time since last update
        return timeOffset + realElapsedSinceLastUpdate
    }
    
    // Fast forward time by specified seconds
    func fastForward(by seconds: TimeInterval) {
        // First, capture current elapsed time (including any real time progression)
        let currentElapsed = getElapsedTime()
        
        // Update the offset to include current elapsed + fast forward amount
        timeOffset = currentElapsed + seconds
        
        // Reset the last update time to now (so we start measuring real time from this point)
        lastRealTimeUpdate = Date()
        
        // Also advance the guideline system timer
        guidelineSystem.elapsedTime += seconds
    }
    
    private func triggerAttentionEffect() {
        shouldShowAttentionEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.shouldShowAttentionEffect = false
        }
    }
}
