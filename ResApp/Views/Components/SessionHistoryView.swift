import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject var sessionStorageService: SessionStorageService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: FilterType = .all
    @State private var showingDeleteConfirmation = false
    @State private var sessionToDelete: ResuscitationSession?
    @State private var showingClearAllConfirmation = false
    @State private var isExporting = false
    @State private var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case sessionDetail(ResuscitationSession)
        case editSession(ResuscitationSession)
        case shareData(Data)
        
        var id: String {
            switch self {
            case .sessionDetail(let session): return "detail-\(session.id)"
            case .editSession(let session): return "edit-\(session.id)"
            case .shareData: return "share"
            }
        }
    }
    
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
                                    activeSheet = .sessionDetail(session)
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
                                
                                Button(role: .destructive, action: {
                                    sessionToDelete = session
                                    showingDeleteConfirmation = true
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .swipeActions(edge: .leading) {
                                Button(action: {
                                    editSession(session)
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.green)
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
            .toolbar(content: {
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
                                showingClearAllConfirmation = true
                            } label: {
                                Label("Clear All Sessions", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            })
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .sessionDetail(let session):
                NavigationView {
                    SessionDetailContentView(session: session)
                        .environmentObject(sessionStorageService)
                }
            case .editSession(let session):
                EditSessionView(session: session)
                    .environmentObject(sessionStorageService)
            case .shareData(let data):
                ShareSheet(items: [data])
            }
        }
        .alert("Delete Session", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    deleteSession(session)
                }
            }
        } message: {
            Text("Are you sure you want to delete this session? This action cannot be undone.")
        }
        .alert("Clear All Sessions", isPresented: $showingClearAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                sessionStorageService.clearAllSessions()
            }
        } message: {
            Text("Are you sure you want to delete all sessions? This action cannot be undone.")
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            let session = filteredSessions[index]
            sessionStorageService.deleteSession(session)
        }
    }
    
    private func deleteSession(_ session: ResuscitationSession) {
        sessionStorageService.deleteSession(session)
        sessionToDelete = nil
    }
    
    private func exportAllSessions() {
        guard !isExporting else { return }
        isExporting = true
        
        let combinedPDF = PDFExportService.shared.exportMultipleSessionsToPDF(sessionStorageService.completedSessions, title: "All Sessions Report")
        
        guard !combinedPDF.isEmpty else {
            isExporting = false
            return
        }
        
        self.activeSheet = .shareData(combinedPDF)
        self.isExporting = false
    }
    
    private func exportFilteredSessions() {
        guard !isExporting else { return }
        isExporting = true
        
        let title = "\(selectedFilter.rawValue) Report"
        let combinedPDF = PDFExportService.shared.exportMultipleSessionsToPDF(filteredSessions, title: title)
        
        guard !combinedPDF.isEmpty else {
            isExporting = false
            return
        }
        
        self.activeSheet = .shareData(combinedPDF)
        self.isExporting = false
    }
    
    private func exportSingleSession(_ session: ResuscitationSession) {
        guard !isExporting else { return }
        isExporting = true
        
        let singlePDF = PDFExportService.shared.exportSessionToPDF(session)
        
        guard !singlePDF.isEmpty else {
            isExporting = false
            return
        }
        
        self.activeSheet = .shareData(singlePDF)
        self.isExporting = false
    }
    
    private func editSession(_ session: ResuscitationSession) {
        self.activeSheet = .editSession(session)
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