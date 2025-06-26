import SwiftUI
import Foundation

// MARK: - Date Extensions
extension Date {
    func timeIntervalSinceResuscitationStart(_ startTime: Date?) -> TimeInterval {
        guard let startTime = startTime else { return 0 }
        return self.timeIntervalSince(startTime)
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    func formattedDuration() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Color Extensions
extension Color {
    static let resuscitationRed = Color.red
    static let resuscitationGreen = Color.green
    static let resuscitationBlue = Color.blue
    static let resuscitationOrange = Color.orange
    static let resuscitationYellow = Color.yellow
    
    // Emergency colors with specific semantic meaning
    static let criticalAlert = Color.red
    static let warningAlert = Color.orange
    static let infoAlert = Color.blue
    static let successAlert = Color.green
} 