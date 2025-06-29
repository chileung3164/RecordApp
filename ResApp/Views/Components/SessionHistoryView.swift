import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject var sessionStorageService: SessionStorageService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: FilterType = .all
    @State private var sessionToShow: ResuscitationSession?
    @State private var showingShareSheet = false
    @State private var pdfData: Data?
    
    private enum FilterType: String, CaseIterable {
        case all = "All Sessions"
        case training = "Training"
        case clinical = "Clinical"
    }
    
    private var filteredSessions: [ResuscitationSession] {
        switch selectedFilter {
        case .all:
            return sessionStorageService.completedSessions
        case .training:
            return sessionStorageService.trainingSessions
        case .clinical:
            return sessionStorageService.clinicalSessions
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Segment Control
                if sessionStorageService.totalSessions > 0 {
                    VStack(spacing: 16) {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(FilterType.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        
                        // Stats Summary
                        HStack(spacing: 20) {
                            CleanStatCard(
                                title: "Total Sessions",
                                value: "\(sessionStorageService.totalSessions)"
                            )
                            
                            CleanStatCard(
                                title: "Training Sessions",
                                value: "\(sessionStorageService.trainingSessions.count)"
                            )
                            
                            CleanStatCard(
                                title: "Clinical Sessions",
                                value: "\(sessionStorageService.clinicalSessions.count)"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    .background(Color(.systemGray6))
                }
                
                // Sessions List
                if filteredSessions.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("No Sessions Found")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Complete your first resuscitation session to see it here")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredSessions) { session in
                            SessionRowView(session: session) {
                                sessionToShow = session
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    exportSingleSession(session)
                                }) {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        // Refresh functionality if needed in the future
                    }
                }
            }
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if !filteredSessions.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: exportAllSessions) {
                                Label("Export All Sessions", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: exportFilteredSessions) {
                                Label("Export Filtered Sessions", systemImage: "doc.badge.plus")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                sessionStorageService.clearAllSessions()
                            } label: {
                                Label("Clear All Sessions", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .sheet(item: $sessionToShow) { session in
            NavigationView {
                SessionDetailContentView(session: session)
                    .environmentObject(sessionStorageService)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            let session = filteredSessions[index]
            sessionStorageService.deleteSession(session)
        }
    }
    
    private func exportAllSessions() {
        let combinedPDF = PDFExportService.shared.exportMultipleSessionsToPDF(sessionStorageService.completedSessions, title: "All Sessions Report")
        pdfData = combinedPDF
        showingShareSheet = true
    }
    
    private func exportFilteredSessions() {
        let title = "\(selectedFilter.rawValue) Report"
        let combinedPDF = PDFExportService.shared.exportMultipleSessionsToPDF(filteredSessions, title: title)
        pdfData = combinedPDF
        showingShareSheet = true
    }
    
    private func exportSingleSession(_ session: ResuscitationSession) {
        let singlePDF = PDFExportService.shared.exportSessionToPDF(session)
        pdfData = singlePDF
        showingShareSheet = true
    }
}

// MARK: - Session Row View (Clinical Design)
struct SessionRowView: View {
    let session: ResuscitationSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header row with key info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDateTime(session.startTime))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(session.mode.rawValue.uppercased())
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(session.mode == .training ? .blue : .red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(session.formattedDuration)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if session.patientOutcome != .none {
                            Text(session.patientOutcome == .alive ? "ROSC" : "DECEASED")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(session.patientOutcome == .alive ? .green : .red)
                        }
                    }
                }
                
                // Clinical data row
                HStack(spacing: 24) {
                    Text("Events: \(session.eventCount)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if session.shockCount > 0 {
                        Text("Shocks: \(session.shockCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if session.medicationCount > 0 {
                        Text("Medications: \(session.medicationCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.separator))
                    .padding(.leading, 20),
                alignment: .bottom
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Clean Stat Card (Clinical Design)
struct CleanStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
} 