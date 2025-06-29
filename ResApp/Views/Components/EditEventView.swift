import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    
    let originalEvent: ResuscitationEvent
    let sessionStartTime: Date
    let onSave: (ResuscitationEvent) -> Void
    
    @State private var selectedEventType: EventTypeSelection = .startCPR
    @State private var eventTimestamp: Date
    @State private var rhythmText: String = ""
    @State private var joulesToText: String = ""
    @State private var durationText: String = ""
    @State private var medicationText: String = ""
    @State private var alertText: String = ""
    @State private var otherText: String = ""
    @State private var doseNumber: Int = 1
    @State private var timeSinceLastDose: String = ""
    
    enum EventTypeSelection: String, CaseIterable {
        case startCPR = "Start CPR"
        case checkRhythm = "Check Rhythm"
        case shockDelivered = "Shock Delivered"
        case cprCycle = "CPR Cycle"
        case adrenalineFirst = "Adrenaline (1st dose)"
        case adrenalineSecond = "Adrenaline (2nd dose)"
        case adrenalineSubsequent = "Adrenaline (subsequent)"
        case amiodarone = "Amiodarone"
        case startROSC = "ROSC"
        case patientOutcomeAlive = "Patient Alive"
        case patientOutcomeDeath = "Patient Death"
        case medication = "Medication"
        case alert = "Alert"
        case other = "Other"
    }
    
    init(event: ResuscitationEvent, sessionStartTime: Date, onSave: @escaping (ResuscitationEvent) -> Void) {
        self.originalEvent = event
        self.sessionStartTime = sessionStartTime
        self.onSave = onSave
        self._eventTimestamp = State(initialValue: event.timestamp)
        
        // Initialize the event type selection and associated values
        switch event.type {
        case .startCPR:
            self._selectedEventType = State(initialValue: .startCPR)
        case .checkRhythm(let rhythm):
            self._selectedEventType = State(initialValue: .checkRhythm)
            self._rhythmText = State(initialValue: rhythm)
        case .shockDelivered(let joules):
            self._selectedEventType = State(initialValue: .shockDelivered)
            self._joulesToText = State(initialValue: String(joules))
        case .cprCycle(let duration):
            self._selectedEventType = State(initialValue: .cprCycle)
            self._durationText = State(initialValue: duration)
        case .adrenalineFirst:
            self._selectedEventType = State(initialValue: .adrenalineFirst)
        case .adrenalineSecond(let timeSinceLastDose):
            self._selectedEventType = State(initialValue: .adrenalineSecond)
            self._timeSinceLastDose = State(initialValue: timeSinceLastDose)
        case .adrenalineSubsequent(let doseNumber, let timeSinceLastDose):
            self._selectedEventType = State(initialValue: .adrenalineSubsequent)
            self._doseNumber = State(initialValue: doseNumber)
            self._timeSinceLastDose = State(initialValue: timeSinceLastDose)
        case .amiodarone(let doseNumber):
            self._selectedEventType = State(initialValue: .amiodarone)
            self._doseNumber = State(initialValue: doseNumber)
        case .startROSC:
            self._selectedEventType = State(initialValue: .startROSC)
        case .patientOutcomeAlive:
            self._selectedEventType = State(initialValue: .patientOutcomeAlive)
        case .patientOutcomeDeath:
            self._selectedEventType = State(initialValue: .patientOutcomeDeath)
        case .medication(let medication):
            self._selectedEventType = State(initialValue: .medication)
            self._medicationText = State(initialValue: medication)
        case .alert(let message):
            self._selectedEventType = State(initialValue: .alert)
            self._alertText = State(initialValue: message)
        case .other(let description):
            self._selectedEventType = State(initialValue: .other)
            self._otherText = State(initialValue: description)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Type") {
                    Picker("Type", selection: $selectedEventType) {
                        ForEach(EventTypeSelection.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Timing") {
                    DatePicker("Event Time", selection: $eventTimestamp, displayedComponents: [.date, .hourAndMinute])
                    
                    HStack {
                        Text("Relative Time")
                        Spacer()
                        Text(formatRelativeTime(eventTimestamp, startTime: sessionStartTime))
                            .foregroundColor(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                
                // Event-specific fields
                eventSpecificFields
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    @ViewBuilder
    private var eventSpecificFields: some View {
        Section("Event Details") {
            switch selectedEventType {
            case .startCPR, .startROSC, .patientOutcomeAlive, .patientOutcomeDeath, .adrenalineFirst:
                Text("No additional details required")
                    .foregroundColor(.secondary)
                    .italic()
                
            case .checkRhythm:
                TextField("Rhythm (e.g., pVT/VF, PEA/AS)", text: $rhythmText)
                    .autocapitalization(.none)
                
            case .shockDelivered:
                TextField("Joules", text: $joulesToText)
                    .keyboardType(.numberPad)
                
            case .cprCycle:
                TextField("Duration (MM:SS)", text: $durationText)
                    .autocapitalization(.none)
                
            case .adrenalineSecond:
                TextField("Time since last dose", text: $timeSinceLastDose)
                    .autocapitalization(.none)
                
            case .adrenalineSubsequent:
                HStack {
                    Text("Dose Number")
                    Spacer()
                    Picker("Dose", selection: $doseNumber) {
                        ForEach(3...10, id: \.self) { dose in
                            Text("\(dose)").tag(dose)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                TextField("Time since last dose", text: $timeSinceLastDose)
                    .autocapitalization(.none)
                
            case .amiodarone:
                HStack {
                    Text("Dose Number")
                    Spacer()
                    Picker("Dose", selection: $doseNumber) {
                        ForEach(1...5, id: \.self) { dose in
                            Text("\(dose)").tag(dose)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
            case .medication:
                TextField("Medication name and dose", text: $medicationText)
                    .autocapitalization(.words)
                
            case .alert:
                TextField("Alert message", text: $alertText)
                    .autocapitalization(.sentences)
                
            case .other:
                TextField("Event description", text: $otherText)
                    .autocapitalization(.sentences)
            }
        }
    }
    
    private var isFormValid: Bool {
        switch selectedEventType {
        case .startCPR, .startROSC, .patientOutcomeAlive, .patientOutcomeDeath, .adrenalineFirst:
            return true
        case .checkRhythm:
            return !rhythmText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .shockDelivered:
            return Int(joulesToText) != nil
        case .cprCycle:
            return !durationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .adrenalineSecond:
            return !timeSinceLastDose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .adrenalineSubsequent:
            return !timeSinceLastDose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .amiodarone:
            return true
        case .medication:
            return !medicationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .alert:
            return !alertText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .other:
            return !otherText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private func saveEvent() {
        let eventType: ResuscitationEvent.EventType
        
        switch selectedEventType {
        case .startCPR:
            eventType = .startCPR
        case .checkRhythm:
            eventType = .checkRhythm(rhythmText.trimmingCharacters(in: .whitespacesAndNewlines))
        case .shockDelivered:
            eventType = .shockDelivered(Int(joulesToText) ?? 0)
        case .cprCycle:
            eventType = .cprCycle(duration: durationText.trimmingCharacters(in: .whitespacesAndNewlines))
        case .adrenalineFirst:
            eventType = .adrenalineFirst
        case .adrenalineSecond:
            eventType = .adrenalineSecond(timeSinceLastDose: timeSinceLastDose.trimmingCharacters(in: .whitespacesAndNewlines))
        case .adrenalineSubsequent:
            eventType = .adrenalineSubsequent(doseNumber, timeSinceLastDose: timeSinceLastDose.trimmingCharacters(in: .whitespacesAndNewlines))
        case .amiodarone:
            eventType = .amiodarone(doseNumber)
        case .startROSC:
            eventType = .startROSC
        case .patientOutcomeAlive:
            eventType = .patientOutcomeAlive
        case .patientOutcomeDeath:
            eventType = .patientOutcomeDeath
        case .medication:
            eventType = .medication(medicationText.trimmingCharacters(in: .whitespacesAndNewlines))
        case .alert:
            eventType = .alert(alertText.trimmingCharacters(in: .whitespacesAndNewlines))
        case .other:
            eventType = .other(otherText.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        // Create new event with updated information but preserve the original ID
        let updatedEvent = ResuscitationEvent(
            id: originalEvent.id,
            type: eventType,
            timestamp: eventTimestamp
        )
        
        onSave(updatedEvent)
        dismiss()
    }
    
    private func formatRelativeTime(_ eventTime: Date, startTime: Date) -> String {
        let interval = eventTime.timeIntervalSince(startTime)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Extension to allow creating ResuscitationEvent with custom ID
extension ResuscitationEvent {
    init(id: UUID, type: EventType, timestamp: Date) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
    }
}

#Preview {
    EditEventView(
        event: ResuscitationEvent(type: .startCPR, timestamp: Date()),
        sessionStartTime: Date()
    ) { _ in }
} 