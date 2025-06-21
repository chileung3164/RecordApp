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
    
    // CPR Cycle Management
    @Published var currentCPRCycle: Int = 0
    @Published var cprCyclePhase: CPRCyclePhase = .waitingForShock

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
        case cprCycleManagement // Managing 10 CPR cycles
    }
    
    enum CPRCyclePhase {
        case waitingForShock    // Red buttons should blink
        case waitingForCPR      // Yellow CPR button should blink
        case waitingForMedication // Specific medication button should blink
        case cprActive          // CPR timer is running
        case cycleComplete      // Cycle finished, prepare for next
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
        
        // Reset CPR cycle management
        currentCPRCycle = 0
        cprCyclePhase = .waitingForShock
        
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
        case .cprCycleManagement:
            checkCPRCycleGuidance()
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
    
    private func checkCPRCycleGuidance() {
        // Provide guidance based on current CPR cycle phase
        switch cprCyclePhase {
        case .waitingForShock:
            if currentGuideline == nil && selectedRhythm == .shockable {
                showGuideline(
                    message: "CPR Cycle \(currentCPRCycle): Deliver shock first (pVT/VF)",
                    phase: .cprCycleManagement,
                    priority: .critical
                )
            }
        case .waitingForCPR:
            if currentGuideline == nil {
                let rhythmType = selectedRhythm == .shockable ? "pVT/VF" : "PEA/AS"
                showGuideline(
                    message: "CPR Cycle \(currentCPRCycle): Start CPR immediately (\(rhythmType))",
                    phase: .cprCycleManagement,
                    priority: .critical
                )
            }
        case .waitingForMedication:
            if currentGuideline == nil {
                let medicationMessage = getMedicationMessageForCycle(currentCPRCycle)
                let rhythmType = selectedRhythm == .shockable ? "pVT/VF" : "PEA/AS"
                showGuideline(
                    message: "CPR Cycle \(currentCPRCycle): \(medicationMessage) (\(rhythmType))",
                    phase: .cprCycleManagement,
                    priority: .high
                )
            }
        default:
            break
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
        currentPhase = .cprCycleManagement
        currentCPRCycle = 1  // PEA/AS starts directly with CPR Cycle 1
        cprCyclePhase = .waitingForCPR
        
        shouldBlinkRhythmButtons = false
        shouldBlinkShockButtons = false
        shouldBlinkCPRButton = true
        shouldBlinkMedicationButtons = false
        
        showGuideline(
            message: "PEA/AS detected - Start CPR Cycle 1 immediately",
            phase: .cprCycleManagement,
            priority: .critical
        )
        
        print("PEA/AS pathway: Starting CPR Cycle 1 directly (no shock)")
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
            // First shock - transition to CPR
            currentPhase = .postShock
            shouldBlinkShockButtons = false
            shouldBlinkCPRButton = true
            
            showGuideline(
                message: "Shock delivered - Resume CPR immediately",
                phase: .postShock,
                priority: .critical
            )
            
            print("First shock delivered - transitioning to post-shock CPR")
        } else if currentPhase == .cprCycleManagement && cprCyclePhase == .waitingForShock {
            // Shock delivered in CPR cycle - move to CPR phase
            cprCyclePhase = .waitingForCPR
            shouldBlinkShockButtons = false
            shouldBlinkCPRButton = true
            shouldBlinkMedicationButtons = false
            
            showGuideline(
                message: "CPR Cycle \(currentCPRCycle): Shock delivered - Start CPR now",
                phase: .cprCycleManagement,
                priority: .critical
            )
            
            print("CPR Cycle \(currentCPRCycle): Shock delivered - waiting for CPR")
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
        } else if currentPhase == .cprCycleManagement && cprCyclePhase == .waitingForCPR {
            // CPR started in cycle management
            cprCyclePhase = .cprActive
            shouldBlinkCPRButton = false
            
            // Check if this cycle needs medication
            if shouldCycleHaveMedication(currentCPRCycle) {
                cprCyclePhase = .waitingForMedication
                shouldBlinkMedicationButtons = true
                
                let medicationMessage = getMedicationMessageForCycle(currentCPRCycle)
                showGuideline(
                    message: "CPR Cycle \(currentCPRCycle): \(medicationMessage)",
                    phase: .cprCycleManagement,
                    priority: .high
                )
            } else {
                shouldBlinkMedicationButtons = false
                showGuideline(
                    message: "CPR Cycle \(currentCPRCycle): CPR in progress - No medication needed this cycle",
                    phase: .cprCycleManagement,
                    priority: .medium
                )
            }
            
            print("CPR Cycle \(currentCPRCycle): CPR started")
        }
    }
    
    func recordCPRCycleCompleted() {
        if currentPhase == .cprCycleManagement {
            currentCPRCycle += 1
            
            if currentCPRCycle <= 10 {
                // Start next CPR cycle - different behavior for shockable vs non-shockable
                if selectedRhythm == .shockable {
                    // pVT/VF pathway: needs shock before CPR
                    cprCyclePhase = .waitingForShock
                    shouldBlinkShockButtons = true
                    shouldBlinkCPRButton = false
                    shouldBlinkMedicationButtons = false
                    
                    showGuideline(
                        message: "Starting CPR Cycle \(currentCPRCycle) - Check rhythm and deliver shock",
                        phase: .cprCycleManagement,
                        priority: .critical
                    )
                } else if selectedRhythm == .nonShockable {
                    // PEA/AS pathway: go directly to CPR (NO SHOCK)
                    cprCyclePhase = .waitingForCPR
                    shouldBlinkShockButtons = false  // NEVER blink for PEA/AS
                    shouldBlinkCPRButton = true
                    shouldBlinkMedicationButtons = false
                    
                    showGuideline(
                        message: "Starting CPR Cycle \(currentCPRCycle) - Start CPR immediately (PEA/AS - no shock)",
                        phase: .cprCycleManagement,
                        priority: .critical
                    )
                }
                
                print("Starting CPR Cycle \(currentCPRCycle) - \(selectedRhythm == .shockable ? "pVT/VF" : "PEA/AS") pathway")
            } else {
                // All 10 cycles completed
                showGuideline(
                    message: "All 10 CPR cycles completed - Reassess patient condition",
                    phase: .reevaluation,
                    priority: .critical
                )
                
                print("All 10 CPR cycles completed")
            }
        }
    }
    
    func recordFirstCPRCycleCompleted() {
        // Transition from initial CPR to cycle management
        currentPhase = .cprCycleManagement
        currentCPRCycle = 2 // Starting cycle 2
        cprCyclePhase = .waitingForShock
        
        shouldBlinkShockButtons = true
        shouldBlinkCPRButton = false
        shouldBlinkMedicationButtons = false
        
        showGuideline(
            message: "Starting CPR Cycle 2 - Check rhythm and deliver shock",
            phase: .cprCycleManagement,
            priority: .critical
        )
        
        print("First CPR cycle completed - Starting CPR Cycle 2")
    }
    
    private func shouldCycleHaveMedication(_ cycle: Int) -> Bool {
        if selectedRhythm == .shockable {
            // pVT/VF pathway
            switch cycle {
            case 2, 4, 6, 8, 10: return true  // Adrenaline cycles
            case 3, 5: return true            // Amiodarone cycles
            case 7, 9: return false           // No medication cycles
            default: return false
            }
        } else if selectedRhythm == .nonShockable {
            // PEA/AS pathway - only Adrenaline on odd cycles
            switch cycle {
            case 1, 3, 5, 7, 9: return true   // Adrenaline cycles
            case 2, 4, 6, 8, 10: return false // No medication cycles
            default: return false
            }
        }
        return false
    }
    
    private func getMedicationMessageForCycle(_ cycle: Int) -> String {
        if selectedRhythm == .shockable {
            // pVT/VF pathway
            switch cycle {
            case 2, 4, 6, 8, 10: return "Administer Adrenaline"
            case 3: return "Administer Amiodarone 300mg (1st dose)"
            case 5: return "Administer Amiodarone 150mg (2nd dose)"
            default: return "No medication needed this cycle"
            }
        } else if selectedRhythm == .nonShockable {
            // PEA/AS pathway - only Adrenaline
            switch cycle {
            case 1, 3, 5, 7, 9: return "Administer Adrenaline"
            case 2, 4, 6, 8, 10: return "No medication needed this cycle"
            default: return "No medication needed this cycle"
            }
        }
        return "No medication needed this cycle"
    }
    
    func recordMedicationGiven(medication: String) {
        if currentPhase == .cprCycleManagement && cprCyclePhase == .waitingForMedication {
            cprCyclePhase = .cprActive
            shouldBlinkMedicationButtons = false
            
            showGuideline(
                message: "CPR Cycle \(currentCPRCycle): \(medication) administered - Continue CPR",
                phase: .cprCycleManagement,
                priority: .medium
            )
            
            print("CPR Cycle \(currentCPRCycle): \(medication) administered")
        }
    }

    func recordAdrenaline() {
        lastAdrenalineTime = Date()
        print("Adrenaline recorded")
        
        recordMedicationGiven(medication: "Adrenaline")
        dismissCurrentGuideline()
    }
    
    func recordAmiodarone() {
        print("Amiodarone recorded")
        recordMedicationGiven(medication: "Amiodarone")
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
        case .adrenaline:
            return shouldBlinkMedicationButtons && shouldCycleNeedAdrenaline()
        case .amiodarone:
            return shouldBlinkMedicationButtons && shouldCycleNeedAmiodarone()
        case .rosc:
            // ROSC should blink after initial rhythm selection, but not during initial phase
            return currentPhase != .rhythmSelection
        }
    }
    
    private func shouldCycleNeedAdrenaline() -> Bool {
        guard currentPhase == .cprCycleManagement && cprCyclePhase == .waitingForMedication else {
            return false
        }
        
        if selectedRhythm == .shockable {
            // pVT/VF pathway - Adrenaline on cycles 2, 4, 6, 8, 10
            return [2, 4, 6, 8, 10].contains(currentCPRCycle)
        } else if selectedRhythm == .nonShockable {
            // PEA/AS pathway - Adrenaline on cycles 1, 3, 5, 7, 9
            return [1, 3, 5, 7, 9].contains(currentCPRCycle)
        }
        
        return false
    }
    
    private func shouldCycleNeedAmiodarone() -> Bool {
        guard currentPhase == .cprCycleManagement && cprCyclePhase == .waitingForMedication else {
            return false
        }
        
        // Amiodarone only for pVT/VF pathway on cycles 3, 5
        return selectedRhythm == .shockable && [3, 5].contains(currentCPRCycle)
    }
    
    enum ButtonType {
        case rhythm, shock, cpr, medication, adrenaline, amiodarone, rosc
    }
}
