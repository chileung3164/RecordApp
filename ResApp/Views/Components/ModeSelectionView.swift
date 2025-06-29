import SwiftUI

// MARK: - Mode Selection View
struct ModeSelectionView: View {
    @Binding var currentMode: AppMode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header Section
                VStack(spacing: 16) {
                    // App Icon and Title
                    HStack(spacing: 16) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ResApp")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Resuscitation Assistant")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Subtitle
                    Text("Professional medical training and clinical support")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
                
                // MARK: - Mode Selection Cards
                VStack(spacing: 20) {
                    Text("Choose Your Mode")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 16) {
                        // Training Mode Card
                        Button(action: {
                            currentMode = .instructorMode
                        }) {
                            ModeCard(
                                icon: "graduationcap.fill",
                                title: "Training Mode",
                                subtitle: "Medical Education & Simulation",
                                description: "For medical education and simulation scenarios",
                                color: .blue,
                                accentColor: .cyan
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                        
                        // Clinical Mode Card
                        Button(action: {
                            currentMode = .normalUserMode
                        }) {
                            ModeCard(
                                icon: "cross.case.fill",
                                title: "Clinical Mode",
                                subtitle: "Real-Time Patient Care",
                                description: "For actual patient resuscitation scenarios",
                                color: .red,
                                accentColor: .orange
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
                

                
                // MARK: - Footer Section
                VStack(spacing: 20) {
                    // Disclaimer
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 16))
                            Text("Medical Disclaimer")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("This application is designed for educational and training purposes. It does not replace proper medical training, clinical judgment, or established emergency protocols. Always follow your institution's guidelines and seek appropriate medical supervision.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Copyright
                    Text("© 2025 QEH MDSSC. All Rights Reserved.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Mode Card Component
struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon and Title Section
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Card Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}



// MARK: - Medical Session Summary Component
struct MedicalSessionSummary: View {
    @EnvironmentObject var sessionStorageService: SessionStorageService
    @State private var showAllSessions = false
    let currentMode: ResuscitationSession.SessionMode
    
    var filteredSessions: [ResuscitationSession] {
        Array(sessionStorageService.completedSessions.filter { $0.mode == currentMode }.prefix(3))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Log")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Recent \(currentMode.rawValue) Sessions")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showAllSessions = true
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            
            // Session List or Empty State
            if filteredSessions.isEmpty {
                VStack(spacing: 12) {
                    Text("No Sessions Recorded")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Complete a resuscitation session to view detailed logs and performance metrics")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 1) {
                    ForEach(filteredSessions) { session in
                        MedicalSessionRow(session: session)
                        
                        if session.id != filteredSessions.last?.id {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showAllSessions) {
            SessionHistoryView()
        }
    }
}

// MARK: - Medical Session Row
struct MedicalSessionRow: View {
    let session: ResuscitationSession
    @State private var showDetailView = false
    
    var body: some View {
        Button(action: {
            showDetailView = true
        }) {
            HStack(spacing: 16) {
                // Session Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(formatDate(session.startTime))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 12)
                        
                        Text(session.formattedDuration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 12) {
                        Text("\(session.eventCount) events")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        if session.shockCount > 0 {
                            Text("\(session.shockCount) shocks")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        if session.medicationCount > 0 {
                            Text("\(session.medicationCount) medications")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Outcome
                if session.patientOutcome != .none {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("OUTCOME")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(session.patientOutcome == .alive ? "ROSC" : "DECEASED")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(session.patientOutcome == .alive ? .green : .red)
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailView) {
            SessionDetailView(session: session)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 