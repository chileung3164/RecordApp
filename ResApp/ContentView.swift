import SwiftUI

// Add enum for app modes
enum AppMode {
    case modeSelection
    case instructorMode
    case normalUserMode
}

struct ContentView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var currentMode: AppMode = .modeSelection

    var body: some View {
        Group {
            switch currentMode {
            case .modeSelection:
                ModeSelectionView(currentMode: $currentMode)
            case .instructorMode:
                InstructorModeView(currentMode: $currentMode)
            case .normalUserMode:
                NormalUserModeView(currentMode: $currentMode)
            }
        }
        .animation(.default, value: currentMode)
    }
}

// Mode Selection View
struct ModeSelectionView: View {
    @Binding var currentMode: AppMode

    var body: some View {
        VStack(spacing: 40) {
            Text("ResApp")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("Advanced Resuscitation Assistant")
                .font(.title2)
                .multilineTextAlignment(.center)

            Text("Select Mode")
                .font(.title)
                .fontWeight(.semibold)

            VStack(spacing: 20) {
                Button(action: {
                    currentMode = .instructorMode
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 40))
                        Text("Instructor Mode")
                            .font(.title2.bold())
                        Text("Full features for medical professionals")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .cornerRadius(15)
                }

                Button(action: {
                    currentMode = .normalUserMode
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "person")
                            .font(.system(size: 40))
                        Text("Normal User Mode")
                            .font(.title2.bold())
                        Text("Simplified interface for general use")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .background(Color.green)
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
            
            Text("Copyright ©️ 2025 QEH MDSSC. All Rights Reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Instructor Mode View (contains all current functionality)
struct InstructorModeView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @Binding var currentMode: AppMode

    var body: some View {
        Group {
            if resuscitationManager.isResuscitationStarted {
                FunctionalButtonView(
                    onEndResuscitation: {
                        currentMode = .modeSelection
                    },
                    showFastForward: true
                )
            } else {
                InstructorStartView()
            }
        }
        .animation(.default, value: resuscitationManager.isResuscitationStarted)
    }
}

// Normal User Mode View (identical to instructor mode for now)  
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

// Instructor Start View (copy of original StartView)
struct InstructorStartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var isShowingInfo = false

    var body: some View {
        VStack(spacing: 30) {
            Text("ResApp - Instructor Mode")
                .font(.system(size: 36, weight: .bold, design: .rounded))

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

            Button("More Information") {
                isShowingInfo = true
            }
            .sheet(isPresented: $isShowingInfo) {
                InfoView()
            }
            
            Text("Copyright ©️ 2025 QEH MDSSC. All Rights Reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Normal User Start View (simplified version)
struct NormalUserStartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var isShowingInfo = false

    var body: some View {
        VStack(spacing: 30) {
            Text("ResApp - User Mode")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("Simplified Resuscitation Assistant")
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

            Button("More Information") {
                isShowingInfo = true
            }
            .sheet(isPresented: $isShowingInfo) {
                InfoView()
            }
            
            Text("Copyright ©️ 2025 QEH MDSSC. All Rights Reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Keep the original StartView for backward compatibility (will be removed later)
struct StartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var isShowingInfo = false

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

            Button("More Information") {
                isShowingInfo = true
            }
            .sheet(isPresented: $isShowingInfo) {
                InfoView()
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
