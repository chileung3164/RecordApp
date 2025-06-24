import SwiftUI

// Enhanced RecordManager with persistence
class RecordManager: ObservableObject {
    @Published var savedRecords: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "SavedResuscitationRecords"
    
    init() {
        loadRecords()
    }
    
    func saveRecord(_ record: String) {
        savedRecords.append(record)
        saveToUserDefaults()
    }
    
    func deleteRecord(_ record: String) {
        savedRecords.removeAll { $0 == record }
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        userDefaults.set(savedRecords, forKey: recordsKey)
    }
    
    private func loadRecords() {
        if let records = userDefaults.array(forKey: recordsKey) as? [String] {
            savedRecords = records
        }
    }
}

@main
struct ResAppApp: App {
    @StateObject private var resuscitationManager = ResuscitationManager()
    @StateObject private var recordManager = RecordManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(resuscitationManager)
                .environmentObject(recordManager)
        }
    }
}
