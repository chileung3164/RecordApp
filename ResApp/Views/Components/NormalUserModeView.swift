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
                NormalUserStartView()
            }
        }
        .animation(.default, value: resuscitationManager.isResuscitationStarted)
    }
}

// MARK: - Normal User Start View
struct NormalUserStartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var isShowingInfo = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Top spacer
                    Spacer()
                        .frame(minHeight: 60)
                    
                    VStack(spacing: 24) {
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
                    }
                    
                    // Bottom spacer
                    Spacer()
                        .frame(minHeight: 60)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color(.systemBackground))
    }
} 