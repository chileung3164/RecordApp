import SwiftUI

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
