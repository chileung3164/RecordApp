import SwiftUI

// MARK: - Mode Selection View
struct ModeSelectionView: View {
    @Binding var currentMode: AppMode

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let isCompactDevice = screenWidth < 900 // iPad mini and smaller iPads
            let isLargeDevice = screenWidth > 1200 // iPad Pro 12.9"
            
            // Aggressive space optimization for no-scroll layout
            let topPadding: CGFloat = {
                if isCompactDevice {
                    return screenHeight * 0.04 // Very minimal top padding for compact devices
                } else if isLargeDevice {
                    return screenHeight * 0.08 // Moderate top padding for big screens
                } else {
                    return screenHeight * 0.06 // Standard minimal padding
                }
            }()
            
            let cardSpacing: CGFloat = {
                if isCompactDevice {
                    return screenHeight * 0.008 // Very tight spacing on small screens
                } else if isLargeDevice {
                    return screenHeight * 0.015 // More spacing on larger screens
                } else {
                    return screenHeight * 0.012 // Standard spacing
                }
            }()
            
            let logoHeight: CGFloat = {
                if isCompactDevice {
                    return min(screenHeight * 0.08, 60) // Much smaller logos on compact devices
                } else if isLargeDevice {
                    return min(screenHeight * 0.12, 100) // Moderate logos on big screens
                } else {
                    return min(screenHeight * 0.10, 80) // Standard logo size
                }
            }()
            
            let sectionSpacing = screenHeight * 0.02 // Tight section spacing
            let horizontalPadding = max(screenWidth * 0.03, 20) // Adaptive horizontal padding
            
            VStack(spacing: 0) {
                // MARK: - Mode Selection Cards Section (Fixed Height)
                VStack(spacing: sectionSpacing) {
                    Text("Choose Your Mode")
                        .font(.system(size: adaptiveTitleSize(for: screenWidth), weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.bottom, isCompactDevice ? 4 : 8)
                    
                    VStack(spacing: cardSpacing) {
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
                                accentColor: .cyan,
                                geometry: geometry
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
                                accentColor: .orange,
                                geometry: geometry
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .padding(.top, topPadding)
                
                Spacer() // Dynamic spacer to push footer to bottom
                
                // MARK: - Footer Section (Minimal Design)
                VStack(spacing: isCompactDevice ? 8 : 12) {
                    // Disclaimer - Compact version
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: isCompactDevice ? 12 : 14))
                            Text("Medical Disclaimer")
                                .font(.system(size: isCompactDevice ? 12 : 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("This application is designed for educational and training purposes. It does not replace proper medical training, clinical judgment, or established emergency protocols. Always follow your institution's guidelines and seek appropriate medical supervision.")
                            .font(.system(size: adaptiveCompactBodySize(for: screenWidth), weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(1)
                    }
                    .padding(isCompactDevice ? 12 : 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, horizontalPadding)
                    
                    // Organization Logos - Compact responsive sizing
                    HStack {
                        // QEH Logo (Left)
                        Image("QEH")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: logoHeight)
                            .cornerRadius(6)
                        
                        Spacer()
                        
                        // Copyright - Moved between logos for space efficiency
                        Text("© 2025 QEH MDSSC. All Rights Reserved.")
                            .font(.system(size: adaptiveCompactCaptionSize(for: screenWidth), weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        // MDSSC Logo (Right)
                        Image("MDSSC")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: logoHeight)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .padding(.bottom, screenHeight * 0.03) // Minimal bottom padding
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Compact Font Size Helpers (More Aggressive)
    private func adaptiveTitleSize(for screenWidth: CGFloat) -> CGFloat {
        switch screenWidth {
        case ...800: return 18      // iPad mini - smaller title
        case 801...1000: return 20  // Standard iPad, iPad Air
        case 1001...1200: return 22 // iPad Pro 11"
        default: return 24          // iPad Pro 12.9"
        }
    }
    
    private func adaptiveCompactBodySize(for screenWidth: CGFloat) -> CGFloat {
        switch screenWidth {
        case ...800: return 10      // iPad mini - very compact
        case 801...1000: return 11  // Standard iPad, iPad Air
        case 1001...1200: return 12 // iPad Pro 11"
        default: return 13          // iPad Pro 12.9"
        }
    }
    
    private func adaptiveCompactCaptionSize(for screenWidth: CGFloat) -> CGFloat {
        switch screenWidth {
        case ...800: return 8       // iPad mini - very small
        case 801...1000: return 9   // Standard iPad, iPad Air
        case 1001...1200: return 10 // iPad Pro 11"
        default: return 11          // iPad Pro 12.9"
        }
    }
}

// MARK: - Compact Mode Card Component
struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    let accentColor: Color
    let geometry: GeometryProxy
    
    var body: some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let isCompactDevice = screenWidth < 900
        let isLargeDevice = screenWidth > 1200
        
        // More aggressive sizing for no-scroll layout
        let cardPadding: CGFloat = {
            if isCompactDevice {
                return screenWidth * 0.018 // Tighter padding for small screens
            } else if isLargeDevice {
                return screenWidth * 0.022 // Less padding for large screens
            } else {
                return screenWidth * 0.020 // Standard compact padding
            }
        }()
        
        let iconSize: CGFloat = {
            switch screenWidth {
            case ...800: return 20      // iPad mini - smaller icons
            case 801...1000: return 22  // Standard iPad, iPad Air
            case 1001...1200: return 24 // iPad Pro 11"
            default: return 26          // iPad Pro 12.9"
            }
        }()
        
        let titleSize: CGFloat = {
            switch screenWidth {
            case ...800: return 14      // iPad mini - smaller title
            case 801...1000: return 16  // Standard iPad, iPad Air
            case 1001...1200: return 18 // iPad Pro 11"
            default: return 20          // iPad Pro 12.9"
            }
        }()
        
        let subtitleSize: CGFloat = {
            switch screenWidth {
            case ...800: return 10      // iPad mini - smaller subtitle
            case 801...1000: return 11  // Standard iPad, iPad Air
            case 1001...1200: return 12 // iPad Pro 11"
            default: return 13          // iPad Pro 12.9"
            }
        }()
        
        let descriptionSize: CGFloat = {
            switch screenWidth {
            case ...800: return 11      // iPad mini - smaller description
            case 801...1000: return 12  // Standard iPad, iPad Air
            case 1001...1200: return 13 // iPad Pro 11"
            default: return 14          // iPad Pro 12.9"
            }
        }()
        
        // Calculate maximum card height to ensure it fits
        let maxCardHeight = screenHeight * (isCompactDevice ? 0.15 : 0.18)
        
        VStack(spacing: isCompactDevice ? 8 : 12) {
            // Icon and Title Section
            HStack(spacing: isCompactDevice ? 10 : 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCompactDevice ? 40 : 50, height: isCompactDevice ? 40 : 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: subtitleSize, weight: .medium))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: isCompactDevice ? 12 : 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Description - More compact
            Text(description)
                .font(.system(size: descriptionSize, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(cardPadding)
        .frame(maxHeight: maxCardHeight)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: isCompactDevice ? 10 : 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(isCompactDevice ? 10 : 12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
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