import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    
    let sessionStartTime: Date
    let onAdd: (ResuscitationEvent) -> Void
    
    @State private var selectedEventType: EventTypeSelection = .startCPR
    @State private var eventTimestamp: Date = Date()
    @State private var rhythmText: String = ""
    @State private var joulesToText: String = "200"
    @State private var durationText: String = "02:00"
    @State private var medicationText: String = ""
    @State private var alertText: String = ""
    @State private var otherText: String = ""
    @State private var doseNumber: Int = 1
    @State private var timeSinceLastDose: String = "03:00"
    
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
                
                Section {
                    Text("This event will be added to the session and automatically sorted by timestamp.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addEvent()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
        .onAppear {
            // Set default timestamp to now
            eventTimestamp = Date()
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
                
                // Common rhythm options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Options:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("pVT/VF") {
                            rhythmText = "pVT/VF"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("PEA/AS") {
                            rhythmText = "PEA/AS"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Asystole") {
                            rhythmText = "Asystole"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
            case .shockDelivered:
                TextField("Joules", text: $joulesToText)
                    .keyboardType(.numberPad)
                
                // Common joule options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Options:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("150J") {
                            joulesToText = "150"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("200J") {
                            joulesToText = "200"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("360J") {
                            joulesToText = "360"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
            case .cprCycle:
                TextField("Duration (MM:SS)", text: $durationText)
                    .autocapitalization(.none)
                
                // Common duration options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Options:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("02:00") {
                            durationText = "02:00"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("02:30") {
                            durationText = "02:30"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("03:00") {
                            durationText = "03:00"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
            case .adrenalineSecond:
                TextField("Time since last dose", text: $timeSinceLastDose)
                    .autocapitalization(.none)
                
                // Common time options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Options:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("03:00") {
                            timeSinceLastDose = "03:00"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("04:00") {
                            timeSinceLastDose = "04:00"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("05:00") {
                            timeSinceLastDose = "05:00"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
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
                
                // Common medication options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Options:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        Button("Calcium 10ml") {
                            medicationText = "Calcium 10ml"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Magnesium 2g") {
                            medicationText = "Magnesium 2g"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Sodium Bicarbonate") {
                            medicationText = "Sodium Bicarbonate"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Atropine 3mg") {
                            medicationText = "Atropine 3mg"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
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
    
    private func addEvent() {
        let eventType: ResuscitationEvent.EventType
        
        switch selectedEventType {
        case .startCPR:
            eventType = .startCPR
        case .checkRhythm:
            eventType = .checkRhythm(rhythmText.trimmingCharacters(in: .whitespacesAndNewlines))
        case .shockDelivered:
            eventType = .shockDelivered(Int(joulesToText) ?? 200)
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
        
        let newEvent = ResuscitationEvent(type: eventType, timestamp: eventTimestamp)
        onAdd(newEvent)
        dismiss()
    }
    
    private func formatRelativeTime(_ eventTime: Date, startTime: Date) -> String {
        let interval = eventTime.timeIntervalSince(startTime)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    AddEventView(sessionStartTime: Date()) { _ in }
} 