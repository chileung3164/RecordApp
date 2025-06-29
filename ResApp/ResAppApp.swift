import SwiftUI

@main
struct ResAppApp: App {
    @StateObject private var sessionStorageService = SessionStorageService()
    @StateObject private var resuscitationManager: ResuscitationManager
    
    init() {
        let storageService = SessionStorageService()
        let manager = ResuscitationManager(sessionStorageService: storageService)
        _sessionStorageService = StateObject(wrappedValue: storageService)
        _resuscitationManager = StateObject(wrappedValue: manager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(resuscitationManager)
                .environmentObject(sessionStorageService)
        }
    }
}
