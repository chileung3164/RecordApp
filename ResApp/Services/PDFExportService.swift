import UIKit
import PDFKit

class PDFExportService {
    static let shared = PDFExportService()
    private init() {}
    
    // MARK: - Main Export Functions
    func exportSessionToPDF(_ session: ResuscitationSession) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // 8.5 x 11 inches at 72 DPI
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        var currentY: CGFloat = 50
        
        // Page 1: Header and Session Overview
        UIGraphicsBeginPDFPage()
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            return Data()
        }
        
        currentY = drawHeader(context: context, pageRect: pageRect, y: currentY)
        currentY = drawSessionOverview(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawClinicalSummary(session: session, context: context, pageRect: pageRect, y: currentY)
        
        // Check if we need a new page for timeline
        if currentY > pageRect.height - 200 {
            UIGraphicsBeginPDFPage()
            currentY = 50
        }
        
        currentY = drawEventTimeline(session: session, context: context, pageRect: pageRect, y: currentY)
        
        // Page 2: Detailed Analysis (if needed)
        if currentY > pageRect.height - 150 {
            UIGraphicsBeginPDFPage()
            currentY = 50
        }
        
        currentY = drawMedicationSummary(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawCPRAnalysis(session: session, context: context, pageRect: pageRect, y: currentY)
        
        // Footer on last page
        drawFooter(context: context, pageRect: pageRect)
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    func exportMultipleSessionsToPDF(_ sessions: [ResuscitationSession], title: String) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // 8.5 x 11 inches at 72 DPI
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            return Data()
        }
            var currentY: CGFloat = 50
            var isFirstPage = true
            
        for (index, session) in sessions.enumerated() {
            // Start new page for each session (except first)
            if !isFirstPage {
                UIGraphicsBeginPDFPage()
                currentY = 50
            } else {
                UIGraphicsBeginPDFPage()
                // Draw main header only on first page
                currentY = drawMultiSessionHeader(title: title, totalSessions: sessions.count, context: context, pageRect: pageRect, y: currentY)
                isFirstPage = false
            }
            
            // Draw session header
            currentY = drawSessionHeader(session: session, sessionNumber: index + 1, context: context, pageRect: pageRect, y: currentY)
            currentY = drawSessionOverview(session: session, context: context, pageRect: pageRect, y: currentY)
            currentY = drawClinicalSummary(session: session, context: context, pageRect: pageRect, y: currentY)
            
            // Add event timeline if there's space, otherwise new page
            if currentY > pageRect.height - 200 {
                UIGraphicsBeginPDFPage()
                currentY = 50
            }
            
            currentY = drawEventTimeline(session: session, context: context, pageRect: pageRect, y: currentY)
            
            // Add medication summary if applicable
            if currentY > pageRect.height - 150 {
                UIGraphicsBeginPDFPage()
                currentY = 50
            }
            currentY = drawMedicationSummary(session: session, context: context, pageRect: pageRect, y: currentY)
            
            // Add separator between sessions (if not last)
            if index < sessions.count - 1 {
                if currentY > pageRect.height - 100 {
                    UIGraphicsBeginPDFPage()
                    currentY = 50
                } else {
                    currentY += 30
                    // Draw separator line
                    context.setStrokeColor(UIColor.systemBlue.cgColor)
                    context.setLineWidth(2.0)
                    context.move(to: CGPoint(x: 50, y: currentY))
                    context.addLine(to: CGPoint(x: pageRect.width - 50, y: currentY))
                    context.strokePath()
                    currentY += 30
                }
            }
        }
        
        // Footer on last page
        drawFooter(context: context, pageRect: pageRect)
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    // MARK: - Multi-Session Specific Functions
    private func drawMultiSessionHeader(title: String, totalSessions: Int, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Main Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.black
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2, y: currentY, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += titleSize.height + 10
        
        // Session count
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blue
        ]
        let subtitle = "Total Sessions: \(totalSessions)"
        let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
        let subtitleRect = CGRect(x: (pageRect.width - subtitleSize.width) / 2, y: currentY, width: subtitleSize.width, height: subtitleSize.height)
        subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
        currentY += subtitleSize.height + 5
        
        // Generation date
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let dateText = "Generated on \(formatDateTime(Date()))"
        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(x: (pageRect.width - dateSize.width) / 2, y: currentY, width: dateSize.width, height: dateSize.height)
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
        currentY += dateSize.height + 30
        
        // Separator line
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 50, y: currentY))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: currentY))
        context.strokePath()
        currentY += 20
        
        return currentY
    }
    
    private func drawSessionHeader(session: ResuscitationSession, sessionNumber: Int, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemBlue
        ]
        
        let headerText = "SESSION #\(sessionNumber)"
        let headerSize = headerText.size(withAttributes: headerAttributes)
        let headerRect = CGRect(x: 50, y: currentY, width: headerSize.width, height: headerSize.height)
        headerText.draw(in: headerRect, withAttributes: headerAttributes)
        
        // Session ID on the right
        let idAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let idText = "ID: \(session.sessionID.uuidString.prefix(8).uppercased())"
        let idSize = idText.size(withAttributes: idAttributes)
        let idRect = CGRect(x: pageRect.width - 50 - idSize.width, y: currentY + 2, width: idSize.width, height: idSize.height)
        idText.draw(in: idRect, withAttributes: idAttributes)
        
        currentY += headerSize.height + 15
        
        return currentY
    }
    
    // MARK: - Header Section
    private func drawHeader(context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // App Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        let title = "RESUSCITATION SESSION REPORT"
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2, y: currentY, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += titleSize.height + 10
        
        // Subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ]
        let subtitle = "Generated on \(formatDateTime(Date()))"
        let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
        let subtitleRect = CGRect(x: (pageRect.width - subtitleSize.width) / 2, y: currentY, width: subtitleSize.width, height: subtitleSize.height)
        subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
        currentY += subtitleSize.height + 30
        
        // Separator line
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 50, y: currentY))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: currentY))
        context.strokePath()
        currentY += 20
        
        return currentY
    }
    
    // MARK: - Session Overview Section
    private func drawSessionOverview(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Section Title
        currentY = drawSectionTitle("SESSION OVERVIEW", context: context, pageRect: pageRect, y: currentY)
        
        let leftMargin: CGFloat = 70
        let labelWidth: CGFloat = 120
        let valueX = leftMargin + labelWidth + 10
        
        // Session ID
        currentY = drawLabelValue("Session ID:", session.sessionID.uuidString.prefix(8).uppercased() + "...", 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        
        // Mode
        currentY = drawLabelValue("Mode:", session.mode.rawValue, 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        
        // Start Time
        currentY = drawLabelValue("Start Time:", formatDateTime(session.startTime), 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        
        // End Time
        currentY = drawLabelValue("End Time:", formatDateTime(session.endTime), 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        
        // Duration
        currentY = drawLabelValue("Total Duration:", session.formattedDuration, 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        
        // Patient Outcome
        let outcomeText = formatPatientOutcome(session.patientOutcome)
        let outcomeColor = getOutcomeColor(session.patientOutcome)
        currentY = drawLabelValue("Patient Outcome:", outcomeText, 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, 
                                 context: context, valueColor: outcomeColor)
        
        return currentY + 20
    }
    
    // MARK: - Clinical Summary Section
    private func drawClinicalSummary(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionTitle("CLINICAL SUMMARY", context: context, pageRect: pageRect, y: currentY)
        
        // Create a 3-column layout for statistics
        let columnWidth = (pageRect.width - 140) / 3
        let startX: CGFloat = 70
        
        // Total Events
        currentY = drawStatBox("Total Events", value: "\(session.eventCount)", 
                              x: startX, y: currentY, width: columnWidth, context: context)
        
        // Shocks Delivered
        drawStatBox("Shocks Delivered", value: "\(session.shockCount)", 
                   x: startX + columnWidth + 10, y: currentY - 60, width: columnWidth, context: context)
        
        // Medications Given
        drawStatBox("Medications", value: "\(session.medicationCount)", 
                   x: startX + (columnWidth + 10) * 2, y: currentY - 60, width: columnWidth, context: context)
        
        return currentY + 20
    }
    
    // MARK: - Event Timeline Section
    private func drawEventTimeline(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionTitle("EVENT TIMELINE", context: context, pageRect: pageRect, y: currentY)
        
        // Timeline headers
        let timeX: CGFloat = 70
        let eventX: CGFloat = 140
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        "TIME".draw(at: CGPoint(x: timeX, y: currentY), withAttributes: headerAttributes)
        "EVENT DESCRIPTION".draw(at: CGPoint(x: eventX, y: currentY), withAttributes: headerAttributes)
        currentY += 25
        
        // Timeline entries
        let eventAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.blue
        ]
        
        for event in session.events {
            let timeText = formatRelativeTime(event.timestamp, startTime: session.startTime)
            let eventText = formatEventDescription(event)
            
            // Check if we need a new page
            if currentY > pageRect.height - 100 {
                UIGraphicsBeginPDFPage()
                currentY = 50
            }
            
            timeText.draw(at: CGPoint(x: timeX, y: currentY), withAttributes: timeAttributes)
            
            // Word wrap for long event descriptions
            let eventRect = CGRect(x: eventX, y: currentY, width: pageRect.width - eventX - 50, height: 50)
            let eventHeight = drawWrappedText(eventText, in: eventRect, attributes: eventAttributes, context: context)
            
            currentY += max(15, eventHeight) + 3
        }
        
        return currentY + 20
    }
    
    // MARK: - Medication Summary Section
    private func drawMedicationSummary(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        let medications = getMedicationSummary(from: session)
        if medications.isEmpty {
            return y
        }
        
        var currentY = y
        currentY = drawSectionTitle("MEDICATION SUMMARY", context: context, pageRect: pageRect, y: currentY)
        
        let leftMargin: CGFloat = 70
        let labelWidth: CGFloat = 200
        let valueX = leftMargin + labelWidth + 10
        
        for (medication, count) in medications.sorted(by: { $0.key < $1.key }) {
            let dosageText = "\(count) dose\(count > 1 ? "s" : "")"
            currentY = drawLabelValue(medication + ":", dosageText, 
                                     leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        }
        
        return currentY + 20
    }
    
    // MARK: - CPR Analysis Section
    private func drawCPRAnalysis(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        let cprCycles = session.events.filter {
            if case .cprCycle(_) = $0.type { return true }
            return false
        }
        
        if cprCycles.isEmpty {
            return currentY
        }
        
        currentY = drawSectionTitle("CPR ANALYSIS", context: context, pageRect: pageRect, y: currentY)
        
        let leftMargin: CGFloat = 70
        let labelWidth: CGFloat = 150
        let valueX = leftMargin + labelWidth + 10
        
        currentY = drawLabelValue("Total CPR Cycles:", "\(cprCycles.count)", 
                                 leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        
        // Calculate average cycle duration if available
        var totalDuration: TimeInterval = 0
        var validCycles = 0
        
        for event in cprCycles {
            if case .cprCycle(let duration) = event.type {
                if let minutes = Double(duration.components(separatedBy: ":").first ?? "0"),
                   let seconds = Double(duration.components(separatedBy: ":").last ?? "0") {
                    totalDuration += minutes * 60 + seconds
                    validCycles += 1
                }
            }
        }
        
        if validCycles > 0 {
            let avgDuration = totalDuration / Double(validCycles)
            let avgMinutes = Int(avgDuration) / 60
            let avgSeconds = Int(avgDuration) % 60
            let avgDurationString = String(format: "%02d:%02d", avgMinutes, avgSeconds)
            
            currentY = drawLabelValue("Average Cycle Duration:", avgDurationString, 
                                     leftMargin: leftMargin, labelWidth: labelWidth, valueX: valueX, y: currentY, context: context)
        }
        
        return currentY + 20
    }
    
    // MARK: - Footer Section
    private func drawFooter(context: CGContext, pageRect: CGRect) {
        let footerY = pageRect.height - 50
        
        // Separator line
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 50, y: footerY - 10))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: footerY - 10))
        context.strokePath()
        
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        
        let footerText = "This report was generated by ResApp - Resuscitation Training & Documentation System"
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerRect = CGRect(x: (pageRect.width - footerSize.width) / 2, y: footerY, width: footerSize.width, height: footerSize.height)
        footerText.draw(in: footerRect, withAttributes: footerAttributes)
    }
    
    // MARK: - Helper Drawing Functions
    private func drawSectionTitle(_ title: String, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        
        let size = title.size(withAttributes: attributes)
        let rect = CGRect(x: 50, y: y, width: size.width, height: size.height)
        title.draw(in: rect, withAttributes: attributes)
        
        // Underline
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2.0)
        context.move(to: CGPoint(x: 50, y: y + size.height + 2))
        context.addLine(to: CGPoint(x: 50 + size.width, y: y + size.height + 2))
        context.strokePath()
        
        return y + size.height + 15
    }
    
    private func drawLabelValue(_ label: String, _ value: String, leftMargin: CGFloat, labelWidth: CGFloat, valueX: CGFloat, y: CGFloat, context: CGContext, valueColor: UIColor = .black) -> CGFloat {
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: valueColor
        ]
        
        label.draw(at: CGPoint(x: leftMargin, y: y), withAttributes: labelAttributes)
        value.draw(at: CGPoint(x: valueX, y: y), withAttributes: valueAttributes)
        
        return y + 18
    }
    
    private func drawStatBox(_ title: String, value: String, x: CGFloat, y: CGFloat, width: CGFloat, context: CGContext) -> CGFloat {
        let boxHeight: CGFloat = 60
        let boxRect = CGRect(x: x, y: y, width: width, height: boxHeight)
        
        // Box background
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(boxRect)
        
        // Box border
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.stroke(boxRect)
        
        // Value (large number)
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        let valueSize = value.size(withAttributes: valueAttributes)
        let valueRect = CGRect(x: x + (width - valueSize.width) / 2, y: y + 8, width: valueSize.width, height: valueSize.height)
        value.draw(in: valueRect, withAttributes: valueAttributes)
        
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: x + (width - titleSize.width) / 2, y: y + boxHeight - 18, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        return y + boxHeight + 10
    }
    
    private func drawWrappedText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any], context: CGContext) -> CGFloat {
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: 0, y: rect.maxY)
        context.scaleBy(x: 1.0, y: -1.0)
        
        CTFrameDraw(frame, context)
        context.restoreGState()
        
        let lines = CTFrameGetLines(frame)
        let lineCount = CFArrayGetCount(lines)
        return CGFloat(lineCount) * 15 // Approximate line height
    }
    
    // MARK: - Formatting Helper Functions
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatRelativeTime(_ eventTime: Date, startTime: Date) -> String {
        let interval = eventTime.timeIntervalSince(startTime)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatEventDescription(_ event: ResuscitationEvent) -> String {
        switch event.type {
        case .startCPR:
            return "CPR Started"
        case .checkRhythm(let rhythm):
            return "Rhythm Check - \(rhythm)"
        case .shockDelivered(let joules):
            return "Defibrillation \(joules)J"
        case .cprCycle(let duration):
            return "CPR Cycle Completed (Duration: \(duration))"
        case .adrenalineFirst:
            return "Adrenaline 1mg (1st dose)"
        case .adrenalineSecond(let timeSinceLastDose):
            return "Adrenaline 1mg (2nd dose) - \(timeSinceLastDose) after previous"
        case .adrenalineSubsequent(let doseNumber, let timeSinceLastDose):
            return "Adrenaline 1mg (\(doseNumber)th dose) - \(timeSinceLastDose) after previous"
        case .amiodarone(let doseNumber):
            return "Amiodarone (\(doseNumber)th dose)"
        case .startROSC:
            return "Return of Spontaneous Circulation (ROSC)"
        case .patientOutcomeAlive:
            return "Patient Status: ROSC Achieved"
        case .patientOutcomeDeath:
            return "Patient Status: Deceased"
        case .medication(let medication):
            return "Medication: \(medication)"
        case .alert(let message):
            return "Alert: \(message)"
        case .other(let description):
            return description
        }
    }
    
    private func formatPatientOutcome(_ outcome: PatientOutcome) -> String {
        switch outcome {
        case .none:
            return "Not Specified"
        case .alive:
            return "ROSC Achieved"
        case .death:
            return "Deceased"
        }
    }
    
    private func getOutcomeColor(_ outcome: PatientOutcome) -> UIColor {
        switch outcome {
        case .none:
            return .gray
        case .alive:
            return .systemGreen
        case .death:
            return .systemRed
        }
    }
    
    private func getMedicationSummary(from session: ResuscitationSession) -> [String: Int] {
        var medications: [String: Int] = [:]
        
        for event in session.events {
            switch event.type {
            case .medication(let medication):
                medications[medication, default: 0] += 1
            case .adrenalineFirst:
                medications["Adrenaline 1mg", default: 0] += 1
            case .adrenalineSecond:
                medications["Adrenaline 1mg", default: 0] += 1
            case .adrenalineSubsequent:
                medications["Adrenaline 1mg", default: 0] += 1
            case .amiodarone:
                medications["Amiodarone", default: 0] += 1
            default:
                break
            }
        }
        
        return medications
    }
} 