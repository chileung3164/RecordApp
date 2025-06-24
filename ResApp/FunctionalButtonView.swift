import SwiftUI
import AVFoundation

struct FunctionalButtonView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @StateObject private var guidelineSystem = SmartResuscitationGuidelineSystem()
    @State private var showEndConfirmation = false
    @State private var showPostCareAlert = false
    @State private var isROSCAchieved = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var defibrillationCounter: Int = 0
    @State private var defibrillationTimer: Timer?
    @State private var cprTimer: Timer?
    @State private var cprCounter: Int = 0
    @State private var cprCycleCounter: Int = 0
    @State private var selectedEnergy: Int = 0
    @State private var patientOutcome: PatientOutcome = .none
    @State private var adrenalineDoses: Int = 0
    @State private var amiodaroneDoses: Int = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var showOtherMedicationSheet = false
    @State private var blinkECG = false
    @State private var showECG = true
    @State private var ecgBlinkTimer: Timer? = nil
    @State private var blinkShock = false
    @State private var showShock = true
    @State private var shockBlinkTimer: Timer? = nil
    @State private var blinkCPR = false
    @State private var showCPR = true
    @State private var cprBlinkTimer: Timer? = nil
    @State private var blinkOutcome = false
    @State private var showOutcome = true
    @State private var outcomeBlinkTimer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var stopwatchTimer: Timer? = nil
    @State private var roscTime: TimeInterval = 0
    @State private var roscTimer: Timer? = nil
    @State private var isROSCActive = false
    @State private var blinkAdrenaline = false
    @State private var showAdrenaline = true
    @State private var adrenalineBlinkTimer: Timer? = nil
    @State private var blinkAmiodarone = false
    @State private var showAmiodarone = true
    @State private var amiodaroneBlinkTimer: Timer? = nil
    @State private var blinkEnergy = true
    @State private var showEnergy = true
    @State private var energyBlinkTimer: Timer? = nil

    enum PatientOutcome {
        case none, alive, death
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Main Control Panel (Left Side) - HCI Optimized Layout
                VStack(spacing: geometry.size.height * 0.018) {
                    // Header with Timer and Patient Outcome (Critical Information)
                    headerSection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.14)
                    
                    // Rhythm Section with Icon (Primary Action)
                    rhythmSection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.16)
                    
                    // Energy Selection Section with Icon (Secondary Action)
                    energySection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.14)
                    
                    // CPR Section with Icon (Primary Action)
                    cprSection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.14)
                    
                    // Medication Section with Icon (Secondary Action)
                    medicationSection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.16)
                    
                    // Other Events Section with Icon (Tertiary Action)
                    otherEventsSection(geometry: geometry)
                        .frame(height: geometry.size.height * 0.12)
                }
                .padding(.horizontal, geometry.size.width * 0.02)
                .padding(.vertical, geometry.size.height * 0.025)
                .frame(width: geometry.size.width * 0.75)
                
                // Resuscitation Record (Right Side)
                ResuscitationRecordView()
                    .frame(width: geometry.size.width * 0.25)
                    .background(Color(UIColor.systemGray6))
            }
        }
        .onAppear {
            guidelineSystem.startGuideline()
            setupAudioPlayer()
            startStopwatch()
            // Reset medication button states before starting blinking
            resetMedicationButtonStates()
            // Start integrated blinking system
            startIntegratedBlinking()
        }
        .onDisappear {
            guidelineSystem.stopGuideline()
            stopAllTimers()
            stopSound()
            // Stop all blinking
            stopAllBlinking()
        }
        .alert("End Resuscitation?", isPresented: $showEndConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End Resuscitation", role: .destructive) {
                endResuscitation()
            }
        } message: {
            Text("Are you sure you want to end the resuscitation? This action cannot be undone.")
        }
    }
    
    private func headerSection(geometry: GeometryProxy) -> some View {
        HStack {
            // Timer - Most Critical Information
            HStack(spacing: geometry.size.width * 0.015) {
                Image(systemName: "stopwatch")
                    .font(.system(size: geometry.size.width * 0.025, weight: .bold))
                    .foregroundColor(.brown)
                Text(formattedElapsedTime)
                    .font(.system(size: geometry.size.width * 0.035, weight: .black, design: .monospaced))
                    .foregroundColor(.brown)
            }
            .padding(.horizontal, geometry.size.width * 0.02)
            .padding(.vertical, geometry.size.height * 0.012)
            .background(Color.brown.opacity(0.15))
            .cornerRadius(geometry.size.width * 0.012)
            
            // Fast Forward Button for debugging - separate from main timer
            Button(action: {
                if cprTimer != nil { // Only work when CPR is active
                    cprCounter = min(cprCounter + 30, 120) // Add 30s, max 120s
                }
            }) {
                Text("+30s")
                    .font(.system(size: geometry.size.width * 0.018, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.horizontal, geometry.size.width * 0.008)
                    .padding(.vertical, geometry.size.height * 0.004)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(geometry.size.width * 0.008)
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.008)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            }
            .opacity(cprTimer != nil ? 1.0 : 0.3) // Only visible when CPR active
            
            Spacer()
            
            // End Button
            Button("End") {
                showEndConfirmation = true
            }
            .font(.system(size: geometry.size.width * 0.02, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, geometry.size.width * 0.02)
            .padding(.vertical, geometry.size.height * 0.01)
            .background(Color.red)
            .cornerRadius(geometry.size.width * 0.01)
            
            // Patient Outcome
            VStack(spacing: geometry.size.height * 0.008) {
                Text("Patient Outcome")
                    .font(.system(size: geometry.size.width * 0.018, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: geometry.size.width * 0.012) {
                    Button("ALIVE") {
                        patientOutcome = .alive
                        stopOutcomeBlinking()
                        resetStopwatch()
                    }
                    .buttonStyle(OutcomeButtonStyle(isSelected: patientOutcome == .alive, color: .green, geometry: geometry))
                    .opacity(showOutcome ? 1.0 : 0.2)
                    .animation(.easeInOut(duration: 0.35), value: showOutcome)
                    
                    Button("DEATH") {
                        patientOutcome = .death
                        stopOutcomeBlinking()
                        resetStopwatch()
                    }
                    .buttonStyle(OutcomeButtonStyle(isSelected: patientOutcome == .death, color: .red, geometry: geometry))
                    .opacity(showOutcome ? 1.0 : 0.2)
                    .animation(.easeInOut(duration: 0.35), value: showOutcome)
                }
            }
        }
        .padding(.horizontal, geometry.size.width * 0.012)
    }
    
    private func rhythmSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.018) {
            // ECG Icon
            VStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: geometry.size.width * 0.022, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(width: geometry.size.width * 0.04, height: geometry.size.width * 0.04)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(geometry.size.width * 0.01)
            }
            
            // Rhythm Buttons - Controlled by guideline system
            HStack(spacing: geometry.size.width * 0.01) {
                RhythmButton(title: "pVT/VF", color: (guidelineSystem.shouldBlinkButton(type: .rhythm) && showECG) ? .blue : .blue.opacity(0.3), geometry: geometry) {
                    recordECGRhythm("pVT/VF")
                }
                
                RhythmButton(title: "PEA/AS", color: (guidelineSystem.shouldBlinkButton(type: .rhythm) && showECG) ? .blue : .blue.opacity(0.3), geometry: geometry) {
                    recordECGRhythm("PEA/AS")
                }
                
                VStack(spacing: geometry.size.height * 0.006) {
                    Text("ROSC")
                        .font(.system(size: geometry.size.width * 0.028, weight: .bold))
                    if !formattedDefibrillationTime.isEmpty {
                        Text(formattedDefibrillationTime)
                            .font(.system(size: geometry.size.width * 0.030, weight: .medium))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background((guidelineSystem.shouldBlinkButton(type: .rosc) && showECG) ? Color(red: 0.2, green: 0.3, blue: 0.7) : Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.3))
                .cornerRadius(geometry.size.width * 0.01)
                .onTapGesture {
                    recordECGRhythm("ROSC")
                    isROSCAchieved = true
                    showPostCareAlert = true
                    print("Debug: ROSC button tapped, starting ROSC timer")
                }
                .onLongPressGesture(minimumDuration: 3.0) {
                    // Debug feature: Add 20 minutes to ROSC time when long pressed
                    print("Debug: ROSC Long press detected!")
                    print("Debug: isROSCAchieved = \(isROSCAchieved), isROSCActive = \(isROSCActive)")
                    print("Debug: Current roscTime = \(roscTime)")
                    
                    // Add 20 minutes regardless of state for debugging
                    roscTime += 1200  // Add 20 minutes (1200 seconds)
                    print("Debug: Added 20 minutes to ROSC time, new time = \(roscTime)")
                    
                    // Start ROSC timer if not already running
                    if !isROSCActive {
                        startROSCStopwatch()
                        print("Debug: Started ROSC timer")
                    }
                }
            }
        }
        .padding(.horizontal, geometry.size.width * 0.012)
    }
    
    private func energySection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.01) {
                            if selectedEnergy > 0 {
                    if [100, 150, 200, 240].contains(selectedEnergy) {
                        Text("Selected: Biphasic \(selectedEnergy)J")
                            .font(.system(size: geometry.size.width * 0.020, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.bottom, 2)
                    } else if selectedEnergy == 360 {
                        Text("Selected: Monophasic 360J")
                            .font(.system(size: geometry.size.width * 0.020, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.bottom, 2)
                    }
                }
            HStack(spacing: geometry.size.width * 0.018) {
                // Lightning Icon
                VStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: geometry.size.width * 0.022, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: geometry.size.width * 0.04, height: geometry.size.width * 0.04)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(geometry.size.width * 0.01)
                }
                // Energy Buttons - Controlled by guideline system
                HStack(spacing: geometry.size.width * 0.008) {
                    ForEach([100, 150, 200, 240], id: \ .self) { energy in
                        EnergyButton(energy: energy, type: "Biphasic", isSelected: selectedEnergy == energy, geometry: geometry, faded: selectedEnergy != energy && selectedEnergy > 0, opacity: (guidelineSystem.shouldBlinkButton(type: .shock) && showEnergy) ? 1.0 : 0.3) {
                            selectedEnergy = energy
                            recordEvent("Defibrillation: Biphasic \(energy)J")
                            guidelineSystem.recordShockDelivered()
                        }
                    }
                    EnergyButton(energy: 360, type: "Monophasic", isSelected: selectedEnergy == 360, geometry: geometry, faded: selectedEnergy != 360 && selectedEnergy > 0, opacity: (guidelineSystem.shouldBlinkButton(type: .shock) && showEnergy) ? 1.0 : 0.3) {
                        selectedEnergy = 360
                        recordEvent("Defibrillation: Monophasic 360J")
                        guidelineSystem.recordShockDelivered()
                    }
                }
            }
            .padding(.horizontal, geometry.size.width * 0.012)
        }
    }
    
    private func cprSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.018) {
            // CPR Icon
            VStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: geometry.size.width * 0.022, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: geometry.size.width * 0.04, height: geometry.size.width * 0.04)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(geometry.size.width * 0.01)
            }
            
            // CPR Single Row Layout - Controlled by guideline system
            Button(action: {
                if cprTimer == nil {
                    cprCycleCounter = completedCPRCycles + 1  // Current cycle = completed + 1
                    startCPRTimer()
                    recordECGRhythm("CPR")
                    guidelineSystem.recordCPRStarted()
                }
            }) {
                HStack(spacing: geometry.size.width * 0.02) {
                    Text("CPR")
                        .font(.system(size: geometry.size.width * 0.030, weight: .black))
                        .foregroundColor(.black)
                    
                    Text(formattedCPRTime)
                        .font(.system(size: geometry.size.width * 0.026, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: geometry.size.width * 0.015) {
                        Text("(cycle) now: \(cprCycleCounter)")
                            .font(.system(size: geometry.size.width * 0.016, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("(cycle) done: \(completedCPRCycles)")
                            .font(.system(size: geometry.size.width * 0.016, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.02)
                .padding(.vertical, geometry.size.height * 0.012)
                .frame(maxWidth: .infinity)
                .background(Color.yellow.opacity((guidelineSystem.shouldBlinkButton(type: .cpr) && showCPR) ? 0.9 : 0.3))
                .cornerRadius(geometry.size.width * 0.01)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.012)
    }
    
    private func medicationSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.018) {
            // Syringe Icon
            VStack {
                Image(systemName: "syringe")
                    .font(.system(size: geometry.size.width * 0.022, weight: .bold))
                    .foregroundColor(.green)
                    .frame(width: geometry.size.width * 0.04, height: geometry.size.width * 0.04)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(geometry.size.width * 0.01)
            }
            
            // Medication Buttons - Dose counter INSIDE like prototype
            HStack(spacing: geometry.size.width * 0.01) {
                MedicationButtonView(
                    title: "Adrenaline",
                    subtitle: "1mg",
                    doses: adrenalineDoses,
                    color: (guidelineSystem.shouldBlinkButton(type: .adrenaline) && showAdrenaline) ? .green : .green.opacity(0.3),
                    geometry: geometry
                ) {
                    adrenalineDoses += 1
                    recordMedication("Adrenaline 1mg")
                    guidelineSystem.recordAdrenaline()
                }
                MedicationButtonView(
                    title: "Amiodarone",
                    subtitle: "1st 300mg\n2nd 150mg",
                    doses: amiodaroneDoses,
                    color: (guidelineSystem.shouldBlinkButton(type: .amiodarone) && showAmiodarone) ? .green : .green.opacity(0.3),
                    geometry: geometry
                ) {
                    amiodaroneDoses += 1
                    let dose = amiodaroneDoses == 1 ? "300mg" : "150mg"
                    recordMedication("Amiodarone \(dose)")
                    guidelineSystem.recordAmiodarone()
                }
                Button(action: {
                    showOtherMedicationSheet = true
                }) {
                    Text("Other\nMedication")
                        .font(.system(size: geometry.size.width * 0.024, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.green.opacity(0.9))
                        .cornerRadius(geometry.size.width * 0.01)
                }
                .sheet(isPresented: $showOtherMedicationSheet) {
                    MedicationPickerSheet { selectedMedication in
                        if let med = selectedMedication {
                            recordMedication(med)
                        }
                        showOtherMedicationSheet = false
                    }
                }
            }
        }
        .padding(.horizontal, geometry.size.width * 0.012)
    }
    
    private func otherEventsSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.018) {
            // Other Icon
            VStack {
                Text("Other")
                    .font(.system(size: geometry.size.width * 0.012, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: geometry.size.width * 0.04, height: geometry.size.width * 0.04)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(geometry.size.width * 0.01)
            }
            
            // Event Buttons
            HStack(spacing: geometry.size.width * 0.01) {
                Button("Intubation") {
                    recordEvent("Intubation")
                }
                .buttonStyle(EventButtonStyle(geometry: geometry))
                
                Button("Other Events") {
                    recordEvent("Other Event")
                }
                .buttonStyle(EventButtonStyle(geometry: geometry))
            }
        }
        .padding(.horizontal, geometry.size.width * 0.012)
    }
    
    // MARK: - Helper Functions
    
    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d'%02d\"", minutes, seconds)
    }
    
    private var formattedDefibrillationTime: String {
        let minutes = Int(roscTime) / 60
        let seconds = Int(roscTime) % 60
        return String(format: "%02d'%02d\"", minutes, seconds)
    }
    
    private var formattedCPRTime: String {
        let minutes = cprCounter / 60
        let seconds = cprCounter % 60
        return String(format: "%02d'%02d\"", minutes, seconds)
    }
    
    private var completedCPRCycles: Int {
        return resuscitationManager.events.filter { 
            if case .alert(let alert) = $0.type { 
                return alert.contains("CPR Cycle") && alert.contains("completed")
            }
            return false
        }.count
    }
    
    private func recordECGRhythm(_ rhythm: String) {
        // If CPR is running, record CPR event with duration
        if cprCounter > 0 {
            let isFirst = resuscitationManager.events.first { if case .ecgRhythm(let r) = $0.type { return r == "CPR" } else { return false } } == nil
            let duration = formattedCPRTime
            let label = isFirst ? "CPR 1st (Duration: \(duration))" : "CPR (Duration: \(duration))"
            resuscitationManager.events.append(ResuscitationEvent(type: .ecgRhythm(label), timestamp: Date()))
            stopCPRTimer()
            cprCounter = 0
        }
        // ROSC stopwatch logic
        if rhythm == "ROSC" {
            startROSCStopwatch()
        } else if rhythm == "pVT/VF" || rhythm == "PEA/AS" {
            resetROSCStopwatch()
        }
        resuscitationManager.events.append(ResuscitationEvent(type: .ecgRhythm(rhythm), timestamp: Date()))
        guidelineSystem.recordECGRhythm(rhythm)
        if rhythm == "ROSC" {
            stopAllTimers()
        } else {
            startOrResetDefibrillationTimer()
        }
    }
    
    private func recordMedication(_ medication: String) {
        resuscitationManager.events.append(ResuscitationEvent(type: .medication(medication), timestamp: Date()))
    }
    
    private func recordEvent(_ event: String) {
        resuscitationManager.events.append(ResuscitationEvent(type: .alert(event), timestamp: Date()))
    }
    
    private func startCPRTimer() {
        cprTimer?.invalidate()
        cprCounter = 0  // Reset counter for the current cycle
        cprTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            cprCounter += 1
            if cprCounter >= 120 { // 2 minutes (120 seconds) completed
                // Stop the current cycle
                self.stopCPRTimer()
                // Mark cycle as done
                let completedCycles = self.resuscitationManager.events.filter { 
                    if case .alert(let alert) = $0.type { 
                        return alert.contains("CPR Cycle") && alert.contains("completed")
                    }
                    return false
                }.count + 1
                self.recordEvent("CPR Cycle \(completedCycles) completed")
                
                // Notify guideline system
                if completedCycles == 1 && self.guidelineSystem.selectedRhythm == .shockable {
                    // pVT/VF pathway: first cycle completed, transition to cycle management
                    self.guidelineSystem.recordFirstCPRCycleCompleted()
                } else {
                    // PEA/AS pathway or subsequent cycles: continue cycle management
                    self.guidelineSystem.recordCPRCycleCompleted()
                }
                
                // Reset for potential next cycle
                self.cprCounter = 0
            }
        }
    }
    
    private func startOrResetDefibrillationTimer() {
        defibrillationTimer?.invalidate()
        defibrillationCounter = 0
        defibrillationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            defibrillationCounter += 1
        }
    }
    
    private func stopAllTimers() {
        cprTimer?.invalidate()
        cprTimer = nil
        defibrillationTimer?.invalidate()
        defibrillationTimer = nil
    }
    
    private func endResuscitation() {
        guidelineSystem.stopGuideline()
        stopAllTimers()
        resuscitationManager.endResuscitation()
        resuscitationManager.isResuscitationStarted = false
    }
    
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "buzzer", withExtension: "wav") else {
            print("Sound file 'buzzer.wav' not found in the app bundle.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }
    
    private func playLoopingSound() {
        audioPlayer?.play()
    }
    
    private func stopSound() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }
    
    // MARK: - Integrated Blinking System
    
    private func startIntegratedBlinking() {
        // Start unified blinking system controlled by guideline system
        ecgBlinkTimer?.invalidate()
        ecgBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            if self.guidelineSystem.shouldBlinkButton(type: .rhythm) {
                self.showECG.toggle()
            } else {
                self.showECG = true
            }
        }
        
        shockBlinkTimer?.invalidate()
        shockBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            if self.guidelineSystem.shouldBlinkButton(type: .shock) {
                self.showEnergy.toggle()
            } else {
                self.showEnergy = true
            }
        }
        
        cprBlinkTimer?.invalidate()
        cprBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            if self.guidelineSystem.shouldBlinkButton(type: .cpr) {
                self.showCPR.toggle()
            } else {
                self.showCPR = true
            }
        }
        
        // Add medication button blinking with debug logging
        adrenalineBlinkTimer?.invalidate()
        adrenalineBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            DispatchQueue.main.async {
                let shouldBlink = self.guidelineSystem.shouldBlinkButton(type: .adrenaline)
                if shouldBlink {
                    self.showAdrenaline.toggle()
                    print("DEBUG: Adrenaline button blinking - showAdrenaline: \(self.showAdrenaline)")
                } else {
                    self.showAdrenaline = true
                }
            }
        }
        // Ensure timer runs on main runloop
        RunLoop.main.add(adrenalineBlinkTimer!, forMode: .common)
        
        amiodaroneBlinkTimer?.invalidate()
        amiodaroneBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            DispatchQueue.main.async {
                let shouldBlink = self.guidelineSystem.shouldBlinkButton(type: .amiodarone)
                if shouldBlink {
                    self.showAmiodarone.toggle()
                    print("DEBUG: Amiodarone button blinking - showAmiodarone: \(self.showAmiodarone)")
                } else {
                    self.showAmiodarone = true
                }
            }
        }
        // Ensure timer runs on main runloop
        RunLoop.main.add(amiodaroneBlinkTimer!, forMode: .common)
        
        print("DEBUG: Integrated blinking system started")
    }
    
    private func stopAllBlinking() {
        ecgBlinkTimer?.invalidate()
        shockBlinkTimer?.invalidate()
        cprBlinkTimer?.invalidate()
        adrenalineBlinkTimer?.invalidate()
        amiodaroneBlinkTimer?.invalidate()
        energyBlinkTimer?.invalidate()
        outcomeBlinkTimer?.invalidate()
        
        showECG = true
        showEnergy = true
        showCPR = true
        showAdrenaline = true
        showAmiodarone = true
        showOutcome = true
        
        print("DEBUG: All blinking stopped and states reset")
    }
    
    private func resetMedicationButtonStates() {
        showAdrenaline = true
        showAmiodarone = true
        blinkAdrenaline = false
        blinkAmiodarone = false
        print("DEBUG: Medication button states reset")
    }
    
    private func startOutcomeBlinkingIfNeeded() {
        outcomeBlinkTimer?.invalidate()
        // Only start blinking if ROSC timer is currently over 20 minutes AND no outcome selected
        if roscTime >= 1200 && patientOutcome == .none && isROSCActive {
            blinkOutcome = true
            showOutcome = true
            outcomeBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
                // Double check timer is still over 20 minutes and ROSC is still active
                if self.roscTime >= 1200 && self.patientOutcome == .none && self.isROSCActive {
                    self.showOutcome.toggle()
                } else {
                    // Stop blinking if conditions no longer met
                    self.stopOutcomeBlinking()
                }
            }
        }
    }
    
    private func stopOutcomeBlinking() {
        blinkOutcome = false
        outcomeBlinkTimer?.invalidate()
        outcomeBlinkTimer = nil
        showOutcome = true
    }
    
    private func stopCPRTimer() {
        cprTimer?.invalidate()
        cprTimer = nil
    }
    
    private func startStopwatch() {
        stopwatchTimer?.invalidate()
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func resetStopwatch() {
        stopwatchTimer?.invalidate()
        elapsedTime = 0
    }
    
    private func startROSCStopwatch() {
        isROSCActive = true
        roscTimer?.invalidate()
        roscTime = 0
        roscTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            roscTime += 1
            // Check if we've reached 20 minutes (1200 seconds) and start blinking
            if roscTime >= 1200 && patientOutcome == .none && !blinkOutcome {
                startOutcomeBlinkingIfNeeded()
            }
        }
    }
    
    private func resetROSCStopwatch() {
        isROSCActive = false
        roscTimer?.invalidate()
        roscTime = 0
        // Stop outcome blinking when ROSC timer is reset
        stopOutcomeBlinking()
    }
    
    private func startAdrenalineBlinkingIfNeeded() {
        adrenalineBlinkTimer?.invalidate()
        let events = resuscitationManager.events
        let lastAdrenaline = events.last { if case .medication(let m) = $0.type { return m.contains("Adrenaline") } else { return false } }
        if let last = lastAdrenaline {
            let interval = Date().timeIntervalSince(last.timestamp)
            if interval >= 300 {
                blinkAdrenaline = true
                showAdrenaline = true
                adrenalineBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
                    if self.blinkAdrenaline {
                        self.showAdrenaline.toggle()
                    } else {
                        self.showAdrenaline = true
                    }
                }
            }
        }
    }
    
    private func stopAdrenalineBlinking() {
        blinkAdrenaline = false
        adrenalineBlinkTimer?.invalidate()
        showAdrenaline = true
    }
    
    private func startAmiodaroneBlinkingIfNeeded() {
        amiodaroneBlinkTimer?.invalidate()
        let events = resuscitationManager.events
        let count = events.filter { if case .medication(let m) = $0.type { return m.contains("Amiodarone") } else { return false } }.count
        if count >= 2 {
            blinkAmiodarone = true
            showAmiodarone = true
            amiodaroneBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
                if self.blinkAmiodarone {
                    self.showAmiodarone.toggle()
                } else {
                    self.showAmiodarone = true
                }
            }
        }
    }
    
    private func stopAmiodaroneBlinking() {
        blinkAmiodarone = false
        amiodaroneBlinkTimer?.invalidate()
        showAmiodarone = true
    }
    
    // Energy blinking is now handled by the integrated blinking system
}

// MARK: - Custom Button Styles

struct OutcomeButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color
    let geometry: GeometryProxy
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: geometry.size.width * 0.020, weight: .bold))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, geometry.size.width * 0.025)
            .padding(.vertical, geometry.size.height * 0.01)
            .background(isSelected ? color : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                    .stroke(color, lineWidth: 2.5)
            )
            .cornerRadius(geometry.size.width * 0.015)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct EventButtonStyle: ButtonStyle {
    let geometry: GeometryProxy
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: geometry.size.width * 0.022, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(geometry.size.width * 0.01)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Custom Views

struct RhythmButton: View {
    let title: String
    var subtitle: String = ""
    let color: Color
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.006) {
                Text(title)
                    .font(.system(size: geometry.size.width * 0.028, weight: .bold))
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: geometry.size.width * 0.030, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color)
            .cornerRadius(geometry.size.width * 0.01)
        }
    }
}

struct EnergyButton: View {
    let energy: Int
    let type: String
    let isSelected: Bool
    let geometry: GeometryProxy
    var faded: Bool = false
    var opacity: Double = 1.0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.008) {
                Text(type)
                    .font(.system(size: geometry.size.width * 0.018, weight: .semibold))
                Text("\(energy)J")
                    .font(.system(size: geometry.size.width * 0.026, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isSelected ? Color.red : Color.red.opacity(0.9))
            .cornerRadius(geometry.size.width * 0.01)
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                    .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
            )
            .opacity(faded ? 0.4 : opacity)
        }
    }
}

struct MedicationButtonView: View {
    let title: String
    let subtitle: String
    let doses: Int
    let color: Color
    let geometry: GeometryProxy
    var opacity: Double = 1.0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.008) {
                HStack {
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.004) {
                        Text(title)
                            .font(.system(size: title == "Amiodarone" ? geometry.size.width * 0.018 : geometry.size.width * 0.022, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(subtitle)
                            .font(.system(size: title == "Amiodarone" ? geometry.size.width * 0.012 : geometry.size.width * 0.015, weight: .medium))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    VStack(spacing: geometry.size.height * 0.002) {
                        Text("dose")
                            .font(.system(size: geometry.size.width * 0.012, weight: .medium))
                        Text("\(doses)")
                            .font(.system(size: geometry.size.width * 0.018, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, geometry.size.width * 0.01)
                    .padding(.vertical, geometry.size.height * 0.006)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(geometry.size.width * 0.008)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, geometry.size.width * 0.015)
            .padding(.vertical, geometry.size.height * 0.01)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(0.9))
            .cornerRadius(geometry.size.width * 0.01)
            .opacity(opacity)
        }
    }
}

struct ResuscitationRecordView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Text("RESUSCITATION RECORD")
                    .font(.system(size: geometry.size.width * 0.065, weight: .bold))
                    .padding(.horizontal, geometry.size.width * 0.06)
                    .padding(.vertical, geometry.size.height * 0.018)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                        ForEach(resuscitationManager.events.reversed()) { event in
                            EventRowView(event: event, geometry: geometry)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.015)
                }
            }
        }
        .background(Color.white)
    }
}

struct EventRowView: View {
    let event: ResuscitationEvent
    let geometry: GeometryProxy
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.006) {
            HStack {
                Text(eventTitle)
                    .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                    .italic(shouldItalicize)
                Spacer()
                Text(timeFormatter.string(from: event.timestamp))
                    .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if let subtitle = eventSubtitle {
                Text(subtitle)
                    .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, geometry.size.height * 0.01)
        .padding(.horizontal, geometry.size.width * 0.04)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(geometry.size.width * 0.025)
    }
    
    private var eventTitle: String {
        switch event.type {
        case .ecgRhythm(let rhythm):
            return "ECG: \(rhythm)"
        case .medication(let med):
            return "Med: \(med)"
        case .defibrillation:
            return "Defibrillation"
        case .alert(let alert):
            return alert
        }
    }
    
    private var eventSubtitle: String? {
        switch event.type {
        case .defibrillation:
            return "Energy delivered"
        default:
            return nil
        }
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    private var shouldItalicize: Bool {
        let events = resuscitationManager.events
        guard let idx = events.firstIndex(where: { $0.id == event.id }) else { return false }
        switch event.type {
        case .ecgRhythm(let rhythm):
            if rhythm == "CPR" {
                if idx == 0 { return false }
                let prev = events[idx-1]
                if case .ecgRhythm(let prevRhythm) = prev.type, prevRhythm == "pVT/VF" {
                    // correct
                } else {
                    return true
                }
            }
            return false
        case .medication(let med):
            if med.contains("Adrenaline") {
                let prev = events[..<idx].last { if case .medication(let m) = $0.type { return m.contains("Adrenaline") } else { return false } }
                if let prev = prev {
                    let interval = event.timestamp.timeIntervalSince(prev.timestamp)
                    if interval < 180 || interval > 300 { return true }
                }
            }
            if med.contains("Amiodarone") || med.contains("Lidocaine") {
                let count = events[...idx].filter { if case .medication(let m) = $0.type { return m.contains("Amiodarone") || m.contains("Lidocaine") } else { return false } }.count
                if count > 2 { return true }
            }
            return false
        case .defibrillation:
            if idx == 0 { return true }
            let prev = events[idx-1]
            if case .ecgRhythm(let prevRhythm) = prev.type, prevRhythm == "pVT/VF" {
                return false
            }
            return true
        case .alert:
            return false
        }
    }
}

struct MedicationPickerSheet: View {
    let medications = [
        ("Atropine", "0.5-1mg IV", "pills.fill"),
        ("Calcium Chloride", "10ml (10% solution)", "testtube.2"),
        ("Dextrose 50%", "50ml IV push", "syringe.fill"),
        ("Dopamine", "5-20mcg/kg/min infusion", "iv.bag.fill"),
        ("Lidocaine", "1-1.5mg/kg IV bolus", "pills.fill"),
        ("Magnesium Sulfate", "2g IV over 10min", "testtube.2"),
        ("Sodium Bicarbonate", "1mEq/kg IV", "flask.fill"),
        ("Other Medication", "Custom entry", "plus.circle.fill")
    ]
    var onSelect: (String?) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        onSelect(nil)
                    }
                    .font(.system(size: geometry.size.width * 0.055, weight: .medium))
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    HStack(spacing: geometry.size.width * 0.02) {
                        Image(systemName: "syringe.fill")
                            .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("Select Medication")
                            .font(.system(size: geometry.size.width * 0.065, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("Cancel") { }
                        .opacity(0)
                        .disabled(true)
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .padding(.vertical, geometry.size.height * 0.02)
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3)),
                    alignment: .bottom
                )
                
                // Medication List
                ScrollView {
                    LazyVStack(spacing: geometry.size.height * 0.015) {
                        ForEach(Array(medications.enumerated()), id: \.offset) { index, medication in
                            MedicationOptionView(
                                title: medication.0,
                                subtitle: medication.1,
                                icon: medication.2,
                                geometry: geometry
                            ) {
                                onSelect(medication.0)
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.04)
                    .padding(.vertical, geometry.size.height * 0.02)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct MedicationOptionView: View {
    let title: String
    let subtitle: String
    let icon: String
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: geometry.size.width * 0.04) {
                // Text Content
                VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
                    Text(title)
                        .font(.system(size: geometry.size.width * 0.065, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.system(size: geometry.size.width * 0.050, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .padding(.horizontal, geometry.size.width * 0.04)
            .padding(.vertical, geometry.size.height * 0.02)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(geometry.size.width * 0.03)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
