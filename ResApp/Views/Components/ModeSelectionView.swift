import SwiftUI

// MARK: - Mode Selection View
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