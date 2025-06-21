import SwiftUI
import Combine

class SmartResuscitationGuidelineSystem: ObservableObject {
    @Published var currentGuideline: ResuscitationGuideline?
    @Published var showGuideline: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var isResuscitationEnded: Bool = false
    
    // Resuscitation State Management
    @Published var currentPhase: ResuscitationPhase = .rhythmSelection
    @Published var selectedRhythm: RhythmType?
    @Published var shouldBlinkRhythmButtons: Bool = true
    @Published var shouldBlinkShockButtons: Bool = false
    @Published var shouldBlinkCPRButton: Bool = false
    @Published var shouldBlinkMedicationButtons: Bool = false

    private var timer: AnyCancellable?
    private var lastAdrenalineTime: Date?
    private var currentECGRhythm: String = ""
    private var lastGuidlineDismissalTime: Date?

    enum ResuscitationPhase {
        case rhythmSelection    // Initial phase - user selects pVT/VF or PEA/AS
        case shockableRhythm   // pVT/VF selected - all red buttons should blink
        case nonShockableRhythm // PEA/AS selected - CPR and medication focus
        case postShock         // After shock delivery
        case cprInProgress     // During CPR cycles
        case medicationPhase   // Focus on medications
        case reevaluation      // Check rhythm again
    }
    
    enum RhythmType {
        case shockable      // pVT/VF
        case nonShockable   // PEA/AS
        case rosc           // Return of Spontaneous Circulation
    }

    struct ResuscitationGuideline: Identifiable {
        let id = UUID()
        let message: String
        let phase: ResuscitationPhase
        let priority: GuidancePriority
        
        enum GuidancePriority {
            case critical, high, medium, low
        }
    }

    func startGuideline() {
        stopTimer()
        elapsedTime = 0
        isResuscitationEnded = false
        lastAdrenalineTime = Date()
        lastGuidlineDismissalTime = nil
        
        // Reset to initial state
        currentPhase = .rhythmSelection
        selectedRhythm = nil
        shouldBlinkRhythmButtons = true
        shouldBlinkShockButtons = false
        shouldBlinkCPRButton = false
        shouldBlinkMedicationButtons = false
        
        startTimer()
        showInitialGuidance()
        print("Guideline system started - awaiting rhythm selection")
    }
    
    private func showInitialGuidance() {
        showGuideline(
            message: "Select initial rhythm: pVT/VF or PEA/AS",
            phase: .rhythmSelection,
            priority: .critical
        )
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedTime += 1
                self?.checkTimeBasedActions()
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func checkTimeBasedActions() {
        let currentTime = Date()

        // Check for time-based guidance based on current phase
        switch currentPhase {
        case .shockableRhythm:
            checkShockableRhythmGuidance()
        case .nonShockableRhythm:
            checkNonShockableRhythmGuidance()
        case .cprInProgress:
            checkCPRGuidance()
        case .medicationPhase:
            checkMedicationGuidance(currentTime: currentTime)
        default:
            break
        }
    }
    
    private func checkShockableRhythmGuidance() {
        // For pVT/VF - prioritize defibrillation
        if currentGuideline == nil {
            showGuideline(
                message: "Charge defibrillator and deliver shock immediately",
                phase: .shockableRhythm,
                priority: .critical
            )
        }
    }
    
    private func checkNonShockableRhythmGuidance() {
        // For PEA/AS - prioritize CPR and medications
        if currentGuideline == nil {
            showGuideline(
                message: "Start high-quality CPR immediately",
                phase: .nonShockableRhythm,
                priority: .critical
            )
        }
    }
    
    private func checkCPRGuidance() {
        // CPR cycle guidance (typically 2 minutes)
        if Int(elapsedTime) % 120 == 0 && elapsedTime > 0 {
            showGuideline(
                message: "Check rhythm after 2 minutes of CPR",
                phase: .reevaluation,
                priority: .high
            )
        }
    }
    
    private func checkMedicationGuidance(currentTime: Date) {
        // Adrenaline guidance (every 3-5 minutes)
        if let lastAdrenaline = lastAdrenalineTime,
           currentTime.timeIntervalSince(lastAdrenaline) >= 180,
           currentGuideline == nil,
           (lastGuidlineDismissalTime == nil || currentTime.timeIntervalSince(lastGuidlineDismissalTime!) >= 60) {
            showGuideline(
                message: "Consider administering Adrenaline (3-5 min intervals)",
                phase: .medicationPhase,
                priority: .high
            )
        }
    }

    func recordECGRhythm(_ rhythm: String) {
        currentECGRhythm = rhythm
        print("ECG Rhythm recorded: \(rhythm)")
        
        // Handle rhythm selection
        switch rhythm {
        case "pVT/VF":
            selectedRhythm = .shockable
            transitionToShockablePhase()
        case "PEA/AS":
            selectedRhythm = .nonShockable
            transitionToNonShockablePhase()
        case "ROSC":
            selectedRhythm = .rosc
            transitionToROSCPhase()
        default:
            break
        }
    }
    
    private func transitionToShockablePhase() {
        currentPhase = .shockableRhythm
        shouldBlinkRhythmButtons = false
        shouldBlinkShockButtons = true
        shouldBlinkCPRButton = false
        shouldBlinkMedicationButtons = false
        
        showGuideline(
            message: "pVT/VF detected - Prepare for immediate defibrillation",
            phase: .shockableRhythm,
            priority: .critical
        )
        
        print("Transitioned to shockable rhythm phase - all red buttons should blink")
    }
    
    private func transitionToNonShockablePhase() {
        currentPhase = .nonShockableRhythm
        shouldBlinkRhythmButtons = false
        shouldBlinkShockButtons = false
        shouldBlinkCPRButton = true
        shouldBlinkMedicationButtons = true
        
        showGuideline(
            message: "PEA/AS detected - Start CPR and prepare medications",
            phase: .nonShockableRhythm,
            priority: .critical
        )
        
        print("Transitioned to non-shockable rhythm phase - CPR and medication focus")
    }
    
    private func transitionToROSCPhase() {
        currentPhase = .reevaluation
        shouldBlinkRhythmButtons = false
        shouldBlinkShockButtons = false
        shouldBlinkCPRButton = false
        shouldBlinkMedicationButtons = false
        
        showGuideline(
            message: "ROSC achieved - Monitor patient and provide post-resuscitation care",
            phase: .reevaluation,
            priority: .high
        )
        
        print("ROSC achieved - transitioning to post-resuscitation care")
    }
    
    func recordShockDelivered() {
        if currentPhase == .shockableRhythm {
            currentPhase = .postShock
            shouldBlinkShockButtons = false
            shouldBlinkCPRButton = true
            
            showGuideline(
                message: "Shock delivered - Resume CPR immediately",
                phase: .postShock,
                priority: .critical
            )
            
            print("Shock delivered - transitioning to post-shock CPR")
        }
    }
    
    func recordCPRStarted() {
        if currentPhase == .nonShockableRhythm || currentPhase == .postShock {
            currentPhase = .cprInProgress
            shouldBlinkCPRButton = false
            shouldBlinkMedicationButtons = true
            
            showGuideline(
                message: "CPR in progress - Consider medications and prepare for rhythm check",
                phase: .cprInProgress,
                priority: .medium
            )
            
            print("CPR started - focus on quality CPR and medications")
        }
    }

    func recordAdrenaline() {
        lastAdrenalineTime = Date()
        print("Adrenaline recorded")
        
        if currentPhase == .medicationPhase || currentPhase == .cprInProgress {
            showGuideline(
                message: "Adrenaline administered - Continue CPR",
                phase: .cprInProgress,
                priority: .medium
            )
        }
        
        dismissCurrentGuideline()
    }
    
    func requestRhythmCheck() {
        currentPhase = .reevaluation
        shouldBlinkRhythmButtons = true
        shouldBlinkShockButtons = false
        shouldBlinkCPRButton = false
        shouldBlinkMedicationButtons = false
        
        showGuideline(
            message: "Check rhythm - Select new rhythm type",
            phase: .reevaluation,
            priority: .high
        )
        
        print("Rhythm check requested - returning to rhythm selection")
    }

    private func showGuideline(message: String, phase: ResuscitationPhase, priority: ResuscitationGuideline.GuidancePriority) {
        DispatchQueue.main.async {
            self.currentGuideline = ResuscitationGuideline(
                message: message,
                phase: phase,
                priority: priority
            )
            self.showGuideline = true
        }
        print("Showing guideline: \(message)")
    }

    func stopGuideline() {
        stopTimer()
        dismissCurrentGuideline()
        isResuscitationEnded = true
        print("Guideline system stopped")
    }

    func resetGuideline() {
        stopTimer()
        elapsedTime = 0
        lastAdrenalineTime = nil
        currentECGRhythm = ""
        lastGuidlineDismissalTime = nil
        dismissCurrentGuideline()
        isResuscitationEnded = false

        startGuideline()
    }

    func dismissCurrentGuideline() {
        DispatchQueue.main.async {
            self.showGuideline = false
            self.currentGuideline = nil
            self.lastGuidlineDismissalTime = Date()
        }
        print("Guideline dismissed")
    }
    
    // Helper methods for UI state
    func shouldBlinkButton(type: ButtonType) -> Bool {
        switch type {
        case .rhythm:
            return shouldBlinkRhythmButtons
        case .shock:
            return shouldBlinkShockButtons
        case .cpr:
            return shouldBlinkCPRButton
        case .medication:
            return shouldBlinkMedicationButtons
        }
    }
    
    enum ButtonType {
        case rhythm, shock, cpr, medication
    }
}
