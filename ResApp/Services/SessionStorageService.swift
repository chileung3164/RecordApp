import Foundation

class SessionStorageService: ObservableObject {
    @Published var completedSessions: [ResuscitationSession] = []
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "completedResuscitationSessions"
    
    init() {
        loadSessions()
        addSampleSessionsIfNeeded()
    }
    
    // MARK: - Public Methods
    
    func saveSession(_ session: ResuscitationSession) {
        completedSessions.insert(session, at: 0) // Insert at beginning for chronological order
        persistSessions()
    }
    
    func deleteSession(_ session: ResuscitationSession) {
        completedSessions.removeAll { $0.id == session.id }
        persistSessions()
    }
    
    func updateSession(_ updatedSession: ResuscitationSession) {
        if let index = completedSessions.firstIndex(where: { $0.id == updatedSession.id }) {
            completedSessions[index] = updatedSession
            persistSessions()
        }
    }
    
    func clearAllSessions() {
        completedSessions.removeAll()
        persistSessions()
    }
    
    // MARK: - Computed Properties
    
    var recentSessions: [ResuscitationSession] {
        Array(completedSessions.prefix(5))
    }
    
    var totalSessions: Int {
        completedSessions.count
    }
    
    var trainingSessions: [ResuscitationSession] {
        completedSessions.filter { $0.mode == .training }
    }
    
    var clinicalSessions: [ResuscitationSession] {
        completedSessions.filter { $0.mode == .clinical }
    }
    
    // MARK: - Private Methods
    
    private func loadSessions() {
        guard let data = userDefaults.data(forKey: sessionsKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            completedSessions = try decoder.decode([ResuscitationSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
            completedSessions = []
        }
    }
    
    private func persistSessions() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(completedSessions)
            userDefaults.set(data, forKey: sessionsKey)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }
    
    private func addSampleSessionsIfNeeded() {
        // Only add sample sessions if none exist and this is the first launch
        let hasAddedSamplesKey = "hasAddedSampleSessions"
        if completedSessions.isEmpty && !userDefaults.bool(forKey: hasAddedSamplesKey) {
            createSampleSessions()
            userDefaults.set(true, forKey: hasAddedSamplesKey)
        }
    }
    
    private func createSampleSessions() {
        let now = Date()
        
        // Sample Training Session 1
        let trainingSession1 = ResuscitationSession(
            sessionID: UUID(),
            startTime: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now,
            endTime: Calendar.current.date(byAdding: .minute, value: 8, to: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now) ?? now,
            events: [
                ResuscitationEvent(type: .startCPR, timestamp: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now),
                ResuscitationEvent(type: .shockDelivered(200), timestamp: Calendar.current.date(byAdding: .minute, value: 2, to: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .medication("Epinephrine 1mg"), timestamp: Calendar.current.date(byAdding: .minute, value: 4, to: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .checkRhythm("VF"), timestamp: Calendar.current.date(byAdding: .minute, value: 6, to: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .patientOutcomeAlive, timestamp: Calendar.current.date(byAdding: .minute, value: 8, to: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now) ?? now)
            ],
            mode: .training,
            patientOutcome: .alive
        )
        
        // Sample Clinical Session 1
        let clinicalSession1 = ResuscitationSession(
            sessionID: UUID(),
            startTime: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
            endTime: Calendar.current.date(byAdding: .minute, value: 15, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now,
            events: [
                ResuscitationEvent(type: .startCPR, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now),
                ResuscitationEvent(type: .shockDelivered(200), timestamp: Calendar.current.date(byAdding: .minute, value: 2, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .adrenalineFirst, timestamp: Calendar.current.date(byAdding: .minute, value: 3, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .shockDelivered(200), timestamp: Calendar.current.date(byAdding: .minute, value: 5, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .amiodarone(1), timestamp: Calendar.current.date(byAdding: .minute, value: 7, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .checkRhythm("Asystole"), timestamp: Calendar.current.date(byAdding: .minute, value: 12, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .patientOutcomeDeath, timestamp: Calendar.current.date(byAdding: .minute, value: 15, to: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) ?? now)
            ],
            mode: .clinical,
            patientOutcome: .death
        )
        
        // Sample Training Session 2
        let trainingSession2 = ResuscitationSession(
            sessionID: UUID(),
            startTime: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now,
            endTime: Calendar.current.date(byAdding: .minute, value: 5, to: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now) ?? now,
            events: [
                ResuscitationEvent(type: .startCPR, timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now),
                ResuscitationEvent(type: .cprCycle(duration: "02:00"), timestamp: Calendar.current.date(byAdding: .minute, value: 2, to: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .startROSC, timestamp: Calendar.current.date(byAdding: .minute, value: 4, to: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now) ?? now),
                ResuscitationEvent(type: .patientOutcomeAlive, timestamp: Calendar.current.date(byAdding: .minute, value: 5, to: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now) ?? now)
            ],
            mode: .training,
            patientOutcome: .alive
        )
        
        completedSessions = [trainingSession2, clinicalSession1, trainingSession1] // Most recent first
        persistSessions()
    }
} 