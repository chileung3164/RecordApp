import SwiftUI

// MARK: - Resuscitation Manager Protocol
protocol ResuscitationManagerProtocol: ObservableObject {
    var isResuscitationStarted: Bool { get set }
    var resuscitationStartTime: Date? { get set }
    var events: [ResuscitationEvent] { get set }
    
    func startResuscitation(mode: ResuscitationSession.SessionMode)
    func endResuscitation()
    func performDefibrillation()
    func recordECGRhythm(_ rhythm: String)
    func administarMedication(_ medication: String)
}

// MARK: - CPR Protocol Manager Protocol
protocol CPRProtocolManagerProtocol {
    var intervalDuration: TimeInterval { get }
    var totalIntervals: Int { get }
    
    func getAlertForInterval(_ interval: Int, currentECGRhythm: String?) -> String?
    func shouldDefibrillate(ecgRhythm: String?) -> Bool
}

// MARK: - Guideline System Protocol
protocol GuidelineSystemProtocol: ObservableObject {
    var currentGuideline: ResuscitationGuideline? { get set }
    var showGuideline: Bool { get set }
    var elapsedTime: TimeInterval { get set }
    
    func startGuideline()
    func stopGuideline()
    func resetGuideline()
}

// MARK: - Audio Service Protocol
protocol AudioServiceProtocol {
    func setupAudioPlayer()
    func playSound()
    func stopSound()
} 