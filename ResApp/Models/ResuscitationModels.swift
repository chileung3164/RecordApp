import SwiftUI

// MARK: - Resuscitation Event Model
struct ResuscitationEvent: Identifiable {
    let id: UUID
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
    
    // Custom initializer for normal creation
    init(type: EventType, timestamp: Date) {
        self.id = UUID()
        self.type = type
        self.timestamp = timestamp
    }
    
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

// MARK: - Resuscitation Session Model
struct ResuscitationSession: Identifiable, Codable {
    let id = UUID()
    let sessionID: UUID
    let startTime: Date
    let endTime: Date
    let events: [ResuscitationEvent]
    let mode: SessionMode
    let patientOutcome: PatientOutcome
    
    enum SessionMode: String, Codable, CaseIterable {
        case training = "Training Mode"
        case clinical = "Clinical Mode"
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var eventCount: Int {
        events.count
    }
    
    var medicationCount: Int {
        events.filter { 
            if case .medication(_) = $0.type { return true }
            return false
        }.count
    }
    
    var shockCount: Int {
        events.filter {
            if case .shockDelivered(_) = $0.type { return true }
            return false
        }.count
    }
}

// MARK: - Extend ResuscitationEvent for Codable
extension ResuscitationEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case id, type, timestamp
    }
    
    enum EventTypeKey: String, CodingKey {
        case eventType, associatedValue, associatedValue2
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        
        var typeContainer = container.nestedContainer(keyedBy: EventTypeKey.self, forKey: .type)
        
        switch type {
        case .startCPR:
            try typeContainer.encode("startCPR", forKey: .eventType)
        case .checkRhythm(let rhythm):
            try typeContainer.encode("checkRhythm", forKey: .eventType)
            try typeContainer.encode(rhythm, forKey: .associatedValue)
        case .shockDelivered(let joules):
            try typeContainer.encode("shockDelivered", forKey: .eventType)
            try typeContainer.encode(joules, forKey: .associatedValue)
        case .cprCycle(let duration):
            try typeContainer.encode("cprCycle", forKey: .eventType)
            try typeContainer.encode(duration, forKey: .associatedValue)
        case .adrenalineFirst:
            try typeContainer.encode("adrenalineFirst", forKey: .eventType)
        case .adrenalineSecond(let timeSinceLastDose):
            try typeContainer.encode("adrenalineSecond", forKey: .eventType)
            try typeContainer.encode(timeSinceLastDose, forKey: .associatedValue)
        case .adrenalineSubsequent(let doseNumber, let timeSinceLastDose):
            try typeContainer.encode("adrenalineSubsequent", forKey: .eventType)
            try typeContainer.encode(doseNumber, forKey: .associatedValue)
            try typeContainer.encode(timeSinceLastDose, forKey: .associatedValue2)
        case .amiodarone(let doseNumber):
            try typeContainer.encode("amiodarone", forKey: .eventType)
            try typeContainer.encode(doseNumber, forKey: .associatedValue)
        case .startROSC:
            try typeContainer.encode("startROSC", forKey: .eventType)
        case .patientOutcomeAlive:
            try typeContainer.encode("patientOutcomeAlive", forKey: .eventType)
        case .patientOutcomeDeath:
            try typeContainer.encode("patientOutcomeDeath", forKey: .eventType)
        case .medication(let medication):
            try typeContainer.encode("medication", forKey: .eventType)
            try typeContainer.encode(medication, forKey: .associatedValue)
        case .alert(let message):
            try typeContainer.encode("alert", forKey: .eventType)
            try typeContainer.encode(message, forKey: .associatedValue)
        case .other(let description):
            try typeContainer.encode("other", forKey: .eventType)
            try typeContainer.encode(description, forKey: .associatedValue)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        let typeContainer = try container.nestedContainer(keyedBy: EventTypeKey.self, forKey: .type)
        let eventType = try typeContainer.decode(String.self, forKey: .eventType)
        
        switch eventType {
        case "startCPR":
            type = .startCPR
        case "checkRhythm":
            let rhythm = try typeContainer.decode(String.self, forKey: .associatedValue)
            type = .checkRhythm(rhythm)
        case "shockDelivered":
            let joules = try typeContainer.decode(Int.self, forKey: .associatedValue)
            type = .shockDelivered(joules)
        case "cprCycle":
            let duration = try typeContainer.decode(String.self, forKey: .associatedValue)
            type = .cprCycle(duration: duration)
        case "adrenalineFirst":
            type = .adrenalineFirst
        case "adrenalineSecond":
            let timeSinceLastDose = try typeContainer.decode(String.self, forKey: .associatedValue)
            type = .adrenalineSecond(timeSinceLastDose: timeSinceLastDose)
        case "adrenalineSubsequent":
            let doseNumber = try typeContainer.decode(Int.self, forKey: .associatedValue)
            let timeSinceLastDose = try typeContainer.decode(String.self, forKey: .associatedValue2)
            type = .adrenalineSubsequent(doseNumber, timeSinceLastDose: timeSinceLastDose)
        case "amiodarone":
            let doseNumber = try typeContainer.decode(Int.self, forKey: .associatedValue)
            type = .amiodarone(doseNumber)
        case "startROSC":
            type = .startROSC
        case "patientOutcomeAlive":
            type = .patientOutcomeAlive
        case "patientOutcomeDeath":
            type = .patientOutcomeDeath
        case "medication":
            let medication = try typeContainer.decode(String.self, forKey: .associatedValue)
            type = .medication(medication)
        case "alert":
            let message = try typeContainer.decode(String.self, forKey: .associatedValue)
            type = .alert(message)
        case "other":
            let description = try typeContainer.decode(String.self, forKey: .associatedValue)
            type = .other(description)
        default:
            type = .other("Unknown event type")
        }
    }
}

// MARK: - Extend PatientOutcome for Codable
extension PatientOutcome: Codable {
    enum CodingKeys: String, CodingKey {
        case outcome
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try container.encode("none", forKey: .outcome)
        case .alive:
            try container.encode("alive", forKey: .outcome)
        case .death:
            try container.encode("death", forKey: .outcome)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let outcome = try container.decode(String.self, forKey: .outcome)
        switch outcome {
        case "none":
            self = .none
        case "alive":
            self = .alive
        case "death":
            self = .death
        default:
            self = .none
        }
    }
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