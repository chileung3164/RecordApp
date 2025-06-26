import SwiftUI

struct ResuscitationSummaryView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resuscitation Summary")
                .font(.system(size: 28, weight: .bold))
            
            if let startTime = resuscitationManager.events.first?.timestamp {
                Text("Starting Time: \(formatDate(startTime))")
                    .font(.system(size: 20))
            }
            
            Divider()
            
            ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(resuscitationManager.events.reversed()) { event in
                        HStack {
                            Text(formatDate(event.timestamp))
                                .font(.system(size: 18, design: .monospaced))
                                .foregroundColor(.secondary)
                            eventIcon(for: event)
                            Text(eventDescription(event))
                                .font(.system(size: 18))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Medication Counts:")
                    .font(.system(size: 20, weight: .bold))
                ForEach(medicationCounts.sorted(by: { $0.key < $1.key }), id: \.key) { medication, count in
                    Text("\(medication): \(count)")
                        .font(.system(size: 18))
                }
            }
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func eventIcon(for event: ResuscitationEvent) -> some View {
        switch event.type {
        case .checkRhythm:
            return Image(systemName: "waveform.path.ecg")
        case .medication:
            return Image(systemName: "pill.fill")
        case .shockDelivered:
            return Image(systemName: "bolt.heart.fill")
        case .patientOutcomeAlive:
            return Image(systemName: "person.fill.checkmark")
        case .patientOutcomeDeath:
            return Image(systemName: "person.fill.xmark")
        case .alert:
            return Image(systemName: "exclamationmark.triangle.fill")
        default:
            return Image(systemName: "circle.fill")
        }
    }
    
    private func eventDescription(_ event: ResuscitationEvent) -> String {
        switch event.type {
        case .startCPR:
            return "Start CPR"
        case .checkRhythm(let rhythm):
            return "Checked rhythm - \(rhythm)"
        case .shockDelivered(let joules):
            return "Shock \(joules)J"
        case .cprCycle(let duration):
            return "CPR (Duration: \(duration))"
        case .adrenalineFirst:
            return "Adrenaline 1st"
        case .adrenalineSecond:
            return "Adrenaline 2nd"
        case .adrenalineSubsequent(let doseNumber, let timeSinceLastDose):
            return "Adrenaline \(doseNumber)th (\(timeSinceLastDose) from last dose)"
        case .amiodarone(let doseNumber):
            return "Amiodarone \(doseNumber)th dose"
        case .startROSC:
            return "Start ROSC"
        case .patientOutcomeAlive:
            return "Patient Outcome: ALIVE"
        case .patientOutcomeDeath:
            return "Patient Outcome: DEATH"
        case .medication(let medication):
            return "Medication: \(medication)"
        case .alert(let message):
            return "Alert: \(message)"
        case .other(let description):
            return description
        }
    }
    
    private var medicationCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for event in resuscitationManager.events {
            if case .medication(let medication) = event.type {
                counts[medication, default: 0] += 1
            }
        }
        return counts
    }
}
