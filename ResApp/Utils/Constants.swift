import Foundation

// MARK: - App Constants
struct AppConstants {
    
    // MARK: - Timing Constants
    struct Timing {
        static let cprCycleDuration: TimeInterval = 120 // 2 minutes
        static let adrenalineInterval: TimeInterval = 180 // 3 minutes
        static let amiodaroneInitialDose: TimeInterval = 300 // 5 minutes
        static let amiodaroneSecondDose: TimeInterval = 900 // 15 minutes
        static let blinkAnimationDuration: Double = 0.35
        static let buttonPressAnimationDuration: Double = 0.1
    }
    
    // MARK: - Medication Constants
    struct Medications {
        static let adrenalineDosage = "1 mg IV"
        static let amiodaroneInitialDosage = "300 mg IV"
        static let amiodaroneSecondDosage = "150 mg IV"
        static let atropineDosage = "0.5 mg IV"
    }
    
    // MARK: - Energy Constants
    struct Energy {
        static let defaultEnergy = [120, 150, 200]
        static let biphasicEnergy = 200
        static let monophasicEnergy = 360
    }
    
    // MARK: - CPR Constants
    struct CPR {
        static let compressionRate = 100...120 // compressions per minute
        static let compressionDepth = 5...6 // centimeters
        static let ventilationRatio = 30 // compressions to 2 breaths
        static let maxCycles = 10
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let smallPadding: CGFloat = 8
        static let mediumPadding: CGFloat = 16
        static let largePadding: CGFloat = 24
        static let buttonHeight: CGFloat = 44
    }
    
    // MARK: - Audio Constants
    struct Audio {
        static let buzzerFileName = "buzzer"
        static let levelUpFileName = "level-up-191997"
        static let audioFileExtension = "wav"
    }
}

// MARK: - App Information
struct AppInfo {
    static let name = "ResApp"
    static let fullName = "Advanced Resuscitation Assistant"
    static let copyright = "Copyright ©️ 2025 QEH MDSSC. All Rights Reserved."
    static let version = "1.0.0"
} 