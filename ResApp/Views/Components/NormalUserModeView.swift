import SwiftUI

// MARK: - Normal User Mode View
struct NormalUserModeView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @Binding var currentMode: AppMode

    var body: some View {
        Group {
            if resuscitationManager.isResuscitationStarted {
                FunctionalButtonView(
                    onEndResuscitation: {
                        currentMode = .modeSelection
                    },
                    showFastForward: false
                )
            } else {
                NormalUserStartView(currentMode: $currentMode)
            }
        }
        .animation(.default, value: resuscitationManager.isResuscitationStarted)
    }
}

// MARK: - Normal User Start View
struct NormalUserStartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @Binding var currentMode: AppMode
    @State private var isShowingInfo = false

    var body: some View {
        VStack(spacing: 0) {
            // Return Button - Prominent and Fixed at top
            HStack {
                Button(action: {
                    currentMode = .modeSelection
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Return")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20) 
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                Spacer()
                
                Text("Clinical Mode")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 15)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 24) {
                    // Top spacer
                    Spacer()
                        .frame(height: 20)
                    
                    // Header Section
                    VStack(spacing: 16) {
                        Text("ResApp - Clinical Mode")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Real-Time Patient Resuscitation Assistant")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }

                    // Start Button
                    Button(action: {
                        resuscitationManager.startResuscitation(mode: .clinical)
                    }) {
                        Text("Start Clinical Session")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)

                    // Session Summary
                    MedicalSessionSummary(currentMode: .clinical)
                        .padding(.horizontal, 20)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button("More Information") {
                            isShowingInfo = true
                        }
                        .foregroundColor(.blue)
                        .sheet(isPresented: $isShowingInfo) {
                            InfoView()
                        }
                        
                        Text("Copyright ©️ 2025 QEH MDSSC. All Rights Reserved.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Bottom spacer
                    Spacer()
                        .frame(height: 60)
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
    }
} 