import SwiftUI

struct ContentView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager

    var body: some View {
        Group {
            if resuscitationManager.isResuscitationStarted {
                FunctionalButtonView()
            } else {
                StartView()
            }
        }
        .animation(.default, value: resuscitationManager.isResuscitationStarted)
    }
}

struct StartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @EnvironmentObject var recordManager: RecordManager
    @State private var isShowingInfo = false
    @State private var isShowingRecords = false

    var body: some View {
        VStack(spacing: 30) {
            Text("ResApp")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("Advanced Resuscitation Assistant for Medical Professionals")
                .font(.title2)
                .multilineTextAlignment(.center)

            Button(action: {
                resuscitationManager.startResuscitation()
            }) {
                Text("Start Resuscitation")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 50)

            HStack(spacing: 20) {
                Button("More Information") {
                    isShowingInfo = true
                }
                .sheet(isPresented: $isShowingInfo) {
                    InfoView()
                }
                
                Button("Record Summary") {
                    isShowingRecords = true
                }
                .sheet(isPresented: $isShowingRecords) {
                    RecordsSummaryView()
                        .environmentObject(recordManager)
                }
            }
            
            Text("Copyright ©️ 2025 QEH MDSSC. All Rights Reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About ResApp")
                    .font(.title.bold())

                Text("ResApp is an advanced resuscitation assistant designed for medical professionals. It provides real-time guidance and tracking during critical resuscitation procedures.")

                Text("Key Features:")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 10) {
                    Text("• ECG Rhythm Monitoring")
                    Text("• Defibrillation Protocol")
                    Text("• Medication Tracking")
                    Text("• Resuscitation Timer")
                    Text("• Event Logging")
                    Text("• Guideline-based Assistance")
                }

                Text("Disclaimer: ResApp is a tool to assist trained medical professionals. It does not replace professional medical judgment. Always follow your institution's guidelines and protocols.")
            }
            .padding()
        }
        .navigationBarTitle("Information", displayMode: .inline)
    }
}

struct RecordsSummaryView: View {
    @EnvironmentObject var recordManager: RecordManager
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: Int?
    @State private var showingDetailView = false
    @State private var selectedRecord: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if recordManager.savedRecords.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        Text("No Records Found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Your resuscitation records will appear here after completing sessions.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(recordManager.savedRecords.indices, id: \.self) { index in
                            RecordCardView(
                                sessionNumber: index + 1,
                                recordText: recordManager.savedRecords[index],
                                onTap: {
                                    selectedRecord = recordManager.savedRecords[index]
                                    showingDetailView = true
                                },
                                onDelete: {
                                    recordToDelete = index
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Resuscitation Records")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Delete Record", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = recordToDelete {
                    recordManager.savedRecords.remove(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to delete this record? This action cannot be undone.")
        }
        .sheet(isPresented: $showingDetailView) {
            ClinicalRecordDetailView(recordText: selectedRecord)
        }
    }
}

struct ClinicalRecordDetailView: View {
    let recordText: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clinical Resuscitation Record")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Complete Event Documentation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider()
                    }
                    .padding(.bottom, 20)
                    
                    // Record Content with better formatting
                    ScrollView {
                        Text(recordText)
                            .font(.system(.callout, design: .monospaced))
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    .frame(minHeight: 300)
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    )
                    
                    // Export Note
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Clinical Documentation")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Text("This record contains complete event documentation suitable for medical records. All events are timestamped and formatted for clinical use.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• ECG rhythm changes with precise timing")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Medication administration record")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Defibrillation attempts and outcomes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Protocol alerts and recommendations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Clinical Record")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Share") {
                    shareRecord()
                }
            )
        }
    }
    
    private func shareRecord() {
        let activityVC = UIActivityViewController(
            activityItems: [recordText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct RecordCardView: View {
    let sessionNumber: Int
    let recordText: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Session \(sessionNumber)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(extractDate(from: recordText))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Tap to view complete clinical record")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .italic()
                }
                
                Spacer()
                
                // Status badge
                Text(extractOutcome(from: recordText))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(outcomeBackgroundColor(extractOutcome(from: recordText)))
                    .foregroundColor(outcomeTextColor(extractOutcome(from: recordText)))
                    .cornerRadius(12)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.text.square")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                    Text("Patient Outcome:")
                        .font(.body)
                        .fontWeight(.medium)
                    Text(extractOutcome(from: recordText))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Duration:")
                        .font(.body)
                        .fontWeight(.medium)
                    Text(extractDuration(from: recordText))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    Text("Total Events:")
                        .font(.body)
                        .fontWeight(.medium)
                    Text(extractEvents(from: recordText))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    Text("Started:")
                        .font(.body)
                        .fontWeight(.medium)
                    Text(extractDate(from: recordText))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action buttons
            VStack(spacing: 8) {
                // Prominent View Record button
                Button(action: onTap) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 16))
                        Text("View Complete Clinical Record")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                // Small, subtle delete button
                HStack {
                    Spacer()
                    Button("Delete Record") {
                        onDelete()
                    }
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                                 }
             }
         }
         .padding()
         .background(Color(UIColor.systemGray6))
         .cornerRadius(12)
         .padding(.horizontal, 4)
         .padding(.vertical, 2)
         }
         .buttonStyle(PlainButtonStyle())
    }
    
    private func extractDate(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Started:") {
                return String(line.dropFirst(8)).trimmingCharacters(in: .whitespaces)
            }
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
    
    private func extractTime(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Session ended:") {
                return String(line.dropFirst(14)).trimmingCharacters(in: .whitespaces)
            }
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    private func extractDuration(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Duration:") {
                return String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            }
        }
        return "Unknown"
    }
    
    private func extractEvents(from text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Events:") {
                return String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
            }
        }
        return "0"
    }
    
    private func extractOutcome(from text: String) -> String {
        if text.contains("Alive") {
            return "Alive"
        } else if text.contains("Death") {
            return "Death"
        } else {
            return "Not specified"
        }
    }
    
    private func outcomeBackgroundColor(_ outcome: String) -> Color {
        switch outcome {
        case "Alive":
            return Color.green.opacity(0.2)
        case "Death":
            return Color.red.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }
    
    private func outcomeTextColor(_ outcome: String) -> Color {
        switch outcome {
        case "Alive":
            return Color.green
        case "Death":
            return Color.red
        default:
            return Color.gray
        }
    }
}
