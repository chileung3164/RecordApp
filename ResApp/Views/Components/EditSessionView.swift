import SwiftUI

struct EditSessionView: View {
    @EnvironmentObject var sessionStorageService: SessionStorageService
    @Environment(\.dismiss) private var dismiss
    
    @State private var editableSession: ResuscitationSession
    @State private var showingEventEditor = false
    @State private var editingEvent: ResuscitationEvent?
    @State private var editingEventIndex: Int?
    @State private var showingDeleteEventConfirmation = false
    @State private var eventToDelete: ResuscitationEvent?
    @State private var showingAddEventSheet = false
    
    init(session: ResuscitationSession) {
        self._editableSession = State(initialValue: session)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Information") {
                    // Session Mode
                    Picker("Mode", selection: $editableSession.mode) {
                        ForEach(ResuscitationSession.SessionMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    // Start Time
                    DatePicker("Start Time", selection: $editableSession.startTime, displayedComponents: [.date, .hourAndMinute])
                    
                    // End Time
                    DatePicker("End Time", selection: $editableSession.endTime, displayedComponents: [.date, .hourAndMinute])
                    
                    // Patient Outcome
                    Picker("Patient Outcome", selection: $editableSession.patientOutcome) {
                        Text("None").tag(PatientOutcome.none)
                        Text("ROSC Achieved").tag(PatientOutcome.alive)
                        Text("Deceased").tag(PatientOutcome.death)
                    }
                }
                
                Section("Session Statistics") {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(formattedDuration)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Events")
                        Spacer()
                        Text("\(editableSession.events.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Medications")
                        Spacer()
                        Text("\(medicationCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Shocks Delivered")
                        Spacer()
                        Text("\(shockCount)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        showingAddEventSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add New Event")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Events (\(editableSession.events.count))")
                } footer: {
                    Text("Tap any event to edit its details, or swipe to delete.")
                }
                
                ForEach(editableSession.events.indices, id: \.self) { index in
                    EditableEventRow(
                        event: editableSession.events[index],
                        startTime: editableSession.startTime
                    ) {
                        editingEvent = editableSession.events[index]
                        editingEventIndex = index
                        showingEventEditor = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            eventToDelete = editableSession.events[index]
                            showingDeleteEventConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: moveEvents)
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSession()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingEventEditor) {
            if let event = editingEvent, let index = editingEventIndex {
                EditEventView(
                    event: event,
                    sessionStartTime: editableSession.startTime
                ) { updatedEvent in
                    editableSession.events[index] = updatedEvent
                    editingEvent = nil
                    editingEventIndex = nil
                }
            }
        }
        .sheet(isPresented: $showingAddEventSheet) {
            AddEventView(sessionStartTime: editableSession.startTime) { newEvent in
                editableSession.events.append(newEvent)
                editableSession.events.sort { $0.timestamp < $1.timestamp }
            }
        }
        .alert("Delete Event", isPresented: $showingDeleteEventConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let event = eventToDelete {
                    deleteEvent(event)
                }
            }
        } message: {
            Text("Are you sure you want to delete this event?")
        }
    }
    
    private var formattedDuration: String {
        let duration = editableSession.endTime.timeIntervalSince(editableSession.startTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var medicationCount: Int {
        editableSession.events.filter { 
            if case .medication(_) = $0.type { return true }
            return false
        }.count
    }
    
    private var shockCount: Int {
        editableSession.events.filter {
            if case .shockDelivered(_) = $0.type { return true }
            return false
        }.count
    }
    
    private func moveEvents(from source: IndexSet, to destination: Int) {
        editableSession.events.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteEvent(_ event: ResuscitationEvent) {
        editableSession.events.removeAll { $0.id == event.id }
        eventToDelete = nil
    }
    
    private func saveSession() {
        sessionStorageService.updateSession(editableSession)
        dismiss()
    }
}

// MARK: - Editable Event Row
struct EditableEventRow: View {
    let event: ResuscitationEvent
    let startTime: Date
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(eventDescription)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatRelativeTime(event.timestamp, startTime: startTime))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var eventDescription: String {
        switch event.type {
        case .startCPR:
            return "CPR Started"
        case .checkRhythm(let rhythm):
            return "Rhythm Check - \(rhythm)"
        case .shockDelivered(let joules):
            return "Defibrillation \(joules)J"
        case .cprCycle(let duration):
            return "CPR Cycle (\(duration))"
        case .adrenalineFirst:
            return "Adrenaline 1mg (1st dose)"
        case .adrenalineSecond(let timeSinceLastDose):
            return "Adrenaline 1mg (2nd dose) - \(timeSinceLastDose) after previous"
        case .adrenalineSubsequent(let doseNumber, let timeSinceLastDose):
            return "Adrenaline 1mg (\(doseNumber)th dose) - \(timeSinceLastDose) after previous"
        case .amiodarone(let doseNumber):
            return "Amiodarone (\(doseNumber)th dose)"
        case .startROSC:
            return "Return of Spontaneous Circulation (ROSC)"
        case .patientOutcomeAlive:
            return "Patient Status: ROSC Achieved"
        case .patientOutcomeDeath:
            return "Patient Status: Deceased"
        case .medication(let medication):
            return "Medication: \(medication)"
        case .alert(let message):
            return "Alert: \(message)"
        case .other(let description):
            return description
        }
    }
    
    private func formatRelativeTime(_ eventTime: Date, startTime: Date) -> String {
        let interval = eventTime.timeIntervalSince(startTime)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    EditSessionView(session: ResuscitationSession(
        sessionID: UUID(),
        startTime: Date(),
        endTime: Date().addingTimeInterval(600),
        events: [],
        mode: .training,
        patientOutcome: .none
    ))
} 