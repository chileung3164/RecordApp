import SwiftUI

// MARK: - Resuscitation Event Model
struct ResuscitationEvent: Identifiable {
    let id = UUID()
    enum EventType {
        case startCPR
        case checkRhythm(String) // pVT/VF, PEA/AS, etc.
        case shockDelivered(Int) // Joules
        case cprCycle(duration: String) // Duration in MM:SS format
        case adrenalineFirst
        case adrenalineSecond(timeSinceLastDose: String)
        case adrenalineSubsequent(Int, timeSinceLastDose: String) // dose number, time since last
        case amiodarone(Int) // dose number
        case startROSC
        case patientOutcomeAlive
        case patientOutcomeDeath
        case medication(String)
        case alert(String)
        case other(String)
    }
    
    let type: EventType
    let timestamp: Date
    
    // Color coding for different event types
    var textColor: Color {
        switch type {
        case .startCPR:
            return .black
        case .checkRhythm:
            return .blue
        case .shockDelivered:
            return .red
        case .cprCycle:
            return .orange
        case .adrenalineFirst, .adrenalineSecond, .adrenalineSubsequent:
            return .green
        case .amiodarone:
            return .purple
        case .startROSC:
            return .black
        case .patientOutcomeAlive:
            return .green
        case .patientOutcomeDeath:
            return .red
        case .medication:
            return .green
        case .alert:
            return .red
        case .other:
            return .gray
        }
    }
}

// MARK: - Patient Outcome Model
enum PatientOutcome {
    case none, alive, death
}

// MARK: - App Mode Model
enum AppMode {
    case modeSelection
    case instructorMode
    case normalUserMode
}

// MARK: - Resuscitation Phase Models
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

// MARK: - Resuscitation Guideline Model
struct ResuscitationGuideline: Identifiable {
    let id = UUID()
    let message: String
    let phase: ResuscitationPhase
    let priority: GuidancePriority
    
    enum GuidancePriority {
        case critical, high, medium, low
    }
} 