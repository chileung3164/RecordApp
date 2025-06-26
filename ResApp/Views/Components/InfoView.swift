import SwiftUI

// MARK: - Info View
struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About ResApp")
                        .font(.title.bold())
                        .padding(.bottom, 10)
                    
                    Text("ResApp is an Advanced Resuscitation Assistant designed to help medical professionals and trained users during emergency resuscitation procedures.")
                        .font(.body)
                    
                    Text("Features:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("• Real-time CPR guidance")
                        Text("• ECG rhythm monitoring")
                        Text("• Medication tracking")
                        Text("• Defibrillation management")
                        Text("• Event logging and summary")
                        Text("• Timer and cycle management")
                    }
                    .font(.body)
                    
                    Text("Modes:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("• Instructor Mode: Full features for medical professionals")
                        Text("• Normal User Mode: Simplified interface for general use")
                    }
                    .font(.body)
                    
                    Text("Important Notice:")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                    
                    Text("This app is designed to assist trained medical personnel. It should not be used as a substitute for proper medical training and should only be used by qualified healthcare professionals.")
                        .font(.body)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("Copyright ©️ 2025 QEH MDSSC. All Rights Reserved.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                }
                .padding()
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 