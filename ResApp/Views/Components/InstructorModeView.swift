import SwiftUI

// MARK: - Instructor Mode View
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

// MARK: - Instructor Start View
struct InstructorStartView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var isShowingInfo = false

    var body: some View {
        VStack(spacing: 30) {
            Text("ResApp - Training Mode")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("Medical Education and Simulation Assistant")
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