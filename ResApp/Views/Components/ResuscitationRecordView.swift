import SwiftUI

// MARK: - Resuscitation Record View
struct ResuscitationRecordView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack {
                Text("RESUSCITATION RECORD")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 1)
            }
            .background(Color.white)
            
            // Events List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(resuscitationManager.events) { event in
                        HStack(alignment: .top, spacing: 8) {
                            // Timestamp
                            Text(formatTime(event.timestamp))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(width: 60, alignment: .leading)
                            
                            // Event Description
                            Text(eventDescription(event))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(event.textColor)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                    }
                }
                .padding(.top, 4)
            }
            .background(Color.white)
            
            Spacer()
        }
        .background(Color.white)
        .overlay(
            // Border
            Rectangle()
                .stroke(Color.black, lineWidth: 2)
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
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
            // Count previous CPR cycles to determine the number
            let cprCount = resuscitationManager.events.filter { 
                if case .cprCycle(_) = $0.type { return true }
                return false
            }.count
            return "CPR \(cprCount)\(ordinalSuffix(cprCount)) (Duration: \(duration))"
        case .adrenalineFirst:
            return "Adrenaline 1st"
        case .adrenalineSecond(let timeSinceLastDose):
            return "Adrenaline 2nd (\(timeSinceLastDose) from last dose)"
        case .adrenalineSubsequent(let doseNumber, let timeSinceLastDose):
            return "Adrenaline \(doseNumber)\(ordinalSuffix(doseNumber)) (\(timeSinceLastDose) from last dose)"
        case .amiodarone(let doseNumber):
            return "Amiodarone \(doseNumber)\(ordinalSuffix(doseNumber)) dose"
        case .startROSC:
            return "Start ROSC"
        case .patientOutcomeAlive:
            return "Patient Outcome: ALIVE"
        case .patientOutcomeDeath:
            return "Patient Outcome: DEATH"
        case .medication(let medication):
            return medication
        case .alert(let message):
            return "Alert: \(message)"
        case .other(let description):
            return description
        }
    }
    
    private func ordinalSuffix(_ number: Int) -> String {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 13 {
            return "th"
        }
        
        switch lastDigit {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
} 