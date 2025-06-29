import SwiftUI

struct SessionDetailView: View {
    let session: ResuscitationSession
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var pdfData: Data?
    
    var body: some View {
        SessionDetailContentView(session: session)
            .sheet(isPresented: $showingShareSheet) {
                if let data = pdfData {
                    ShareSheet(items: [data])
                }
            }
    }
}

// MARK: - Session Detail Content (without NavigationView wrapper)
struct SessionDetailContentView: View {
    let session: ResuscitationSession
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var pdfData: Data?
    
    var body: some View {
        Group {
            if session.events.isEmpty {
                // Show a message if no events are available
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Session Information")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("No Events Recorded")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("This session appears to have no recorded events, but here's the basic session information:")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Session info card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Mode:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(session.mode.rawValue)
                                    .foregroundColor(session.mode == .training ? .blue : .red)
                            }
                            
                            HStack {
                                Text("Start Time:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(formatDateTime(session.startTime))
                            }
                            
                            HStack {
                                Text("End Time:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(formatDateTime(session.endTime))
                            }
                            
                            HStack {
                                Text("Duration:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(session.formattedDuration)
                                    .fontWeight(.semibold)
                            }
                            
                            if session.patientOutcome != .none {
                                HStack {
                                    Text("Outcome:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(session.patientOutcome == .alive ? "ROSC Achieved" : "Deceased")
                                        .foregroundColor(session.patientOutcome == .alive ? .green : .red)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Session Header - Clinical Style
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Session Report")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(session.mode.rawValue.uppercased())
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(session.mode == .training ? .blue : .red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(4)
                                }
                                
                                Spacer()
                                
                                if session.patientOutcome != .none {
                                    Text(session.patientOutcome == .alive ? "ROSC" : "DECEASED")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(session.patientOutcome == .alive ? .green : .red)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(session.patientOutcome == .alive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                            
                            // Time Information
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Start Time:")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDateTime(session.startTime))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Text("End Time:")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDateTime(session.endTime))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Text("Total Duration:")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(session.formattedDuration)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.separator))
                            
                            // Clinical Statistics
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Clinical Summary")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 40) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Total Events")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text("\(session.eventCount)")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Shocks Delivered")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text("\(session.shockCount)")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Medications")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text("\(session.medicationCount)")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.separator))
                        
                        // Event Timeline - Clean Medical Style
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Event Timeline")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(session.events.enumerated().map({ ($0.offset, $0.element) }), id: \.1.id) { index, event in
                                    CleanEventRow(event: event, startTime: session.startTime)
                                    
                                    if index < session.events.count - 1 {
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color(.separator))
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                        }
                        
                        // Medication Summary - Clean Style
                        if !medicationCounts.isEmpty {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.separator))
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Medication Summary")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(medicationCounts.sorted(by: { $0.key < $1.key }), id: \.key) { medication, count in
                                        HStack {
                                            Text(medication)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Text("\(count) dose\(count > 1 ? "s" : "")")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Session Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: exportToPDF) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }
    
    private var medicationCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for event in session.events {
            if case .medication(let medication) = event.type {
                counts[medication, default: 0] += 1
            }
        }
        return counts
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func exportToPDF() {
        let pdfData = PDFExportService.shared.exportSessionToPDF(session)
        self.pdfData = pdfData
        showingShareSheet = true
    }
}

// MARK: - Clean Event Row for Medical Use
struct CleanEventRow: View {
    let event: ResuscitationEvent
    let startTime: Date
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time column - fixed width for alignment
            Text(formatRelativeTime(event.timestamp, startTime: startTime))
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            // Event description
            Text(eventDescription(event))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private func formatRelativeTime(_ eventTime: Date, startTime: Date) -> String {
        let interval = eventTime.timeIntervalSince(startTime)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func eventDescription(_ event: ResuscitationEvent) -> String {
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
} 