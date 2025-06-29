import UIKit
import PDFKit

class PDFExportService {
    static let shared = PDFExportService()
    private init() {}
    
    // MARK: - Document Properties
    private let pageWidth: CGFloat = 612  // 8.5 inches
    private let pageHeight: CGFloat = 792  // 11 inches
    private let margin: CGFloat = 60
    private let contentWidth: CGFloat = 492  // pageWidth - 2*margin
    
    // MARK: - Typography
    private let fonts = (
        title: UIFont.systemFont(ofSize: 20, weight: .bold),
        sectionHeader: UIFont.systemFont(ofSize: 16, weight: .semibold),
        subsectionHeader: UIFont.systemFont(ofSize: 14, weight: .medium),
        body: UIFont.systemFont(ofSize: 11),
        bodyBold: UIFont.systemFont(ofSize: 11, weight: .medium),
        caption: UIFont.systemFont(ofSize: 9),
        monospace: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
    )
    
    // MARK: - Colors
    private let colors = (
        primary: UIColor.black,
        secondary: UIColor.darkGray,
        accent: UIColor.systemBlue,
        success: UIColor.systemGreen,
        warning: UIColor.systemOrange,
        danger: UIColor.systemRed,
        background: UIColor.systemGray6,
        border: UIColor.lightGray
    )
    
    // MARK: - Main Export Functions
    func exportSessionToPDF(_ session: ResuscitationSession) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            return Data()
        }
        
        var currentY: CGFloat = margin
        var pageNumber = 1
        
        // PAGE 1: Medical Report Header & Overview
        UIGraphicsBeginPDFPage()
        currentY = drawMedicalReportHeader(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawExecutiveSummary(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawPatientInformation(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawSessionMetadata(session: session, context: context, pageRect: pageRect, y: currentY)
        
        drawPageFooter(context: context, pageRect: pageRect, pageNumber: pageNumber)
        
        // PAGE 2: Clinical Timeline & Events
        if !session.events.isEmpty {
            pageNumber += 1
            UIGraphicsBeginPDFPage()
            currentY = drawPageHeader(title: "CLINICAL TIMELINE", context: context, pageRect: pageRect, y: margin)
            currentY = drawDetailedEventTimeline(session: session, context: context, pageRect: pageRect, y: currentY)
            drawPageFooter(context: context, pageRect: pageRect, pageNumber: pageNumber)
        }
        
        // PAGE 3: Clinical Analysis & Recommendations
        pageNumber += 1
        UIGraphicsBeginPDFPage()
        currentY = drawPageHeader(title: "CLINICAL ANALYSIS", context: context, pageRect: pageRect, y: margin)
        currentY = drawQualityMetrics(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawMedicationAnalysis(session: session, context: context, pageRect: pageRect, y: currentY)
        currentY = drawCPRQualityAnalysis(session: session, context: context, pageRect: pageRect, y: currentY)
        
        drawPageFooter(context: context, pageRect: pageRect, pageNumber: pageNumber)
        
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
    
    // MARK: - Medical Report Header Functions
    private func drawMedicalReportHeader(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Facility Header - Professional Format
        let facilityName = "MEDICAL TRAINING CENTER"
        let facilityAddr = "Emergency Medicine Department"
        
        let facilityAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.bodyBold,
            .foregroundColor: colors.primary
        ]
        facilityName.draw(at: CGPoint(x: margin, y: currentY), withAttributes: facilityAttrs)
        currentY += 18
        
        let addrAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.body,
            .foregroundColor: colors.secondary
        ]
        facilityAddr.draw(at: CGPoint(x: margin, y: currentY), withAttributes: addrAttrs)
        currentY += 25
        
        // Report Title - Centered
        let title = "CARDIAC ARREST / RESUSCITATION REPORT"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.title,
            .foregroundColor: colors.primary
        ]
        let titleSize = title.size(withAttributes: titleAttrs)
        let titleX = (pageWidth - titleSize.width) / 2
        title.draw(at: CGPoint(x: titleX, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 5
        
        // Report Type Badge
        let typeText = session.mode == .clinical ? "CLINICAL CASE" : "TRAINING SESSION"
        let typeColor = session.mode == .clinical ? colors.danger : colors.accent
        let typeAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.caption,
            .foregroundColor: typeColor
        ]
        let typeSize = typeText.size(withAttributes: typeAttrs)
        let typeX = (pageWidth - typeSize.width) / 2
        
        // Draw background for badge
        let badgeRect = CGRect(x: typeX - 8, y: currentY, width: typeSize.width + 16, height: typeSize.height + 6)
        context.setFillColor(typeColor.withAlphaComponent(0.1).cgColor)
        context.setStrokeColor(typeColor.cgColor)
        context.setLineWidth(1)
        
        let cornerRadius: CGFloat = 3
        let path = UIBezierPath(roundedRect: badgeRect, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.drawPath(using: .fillStroke)
        
        typeText.draw(at: CGPoint(x: typeX, y: currentY + 3), withAttributes: typeAttrs)
        currentY += typeSize.height + 20
        
        // Report Details
        let reportDate = "Report Generated: \(formatDateTimeDetailed(Date()))"
        let reportAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.caption,
            .foregroundColor: colors.secondary
        ]
        let reportSize = reportDate.size(withAttributes: reportAttrs)
        let reportX = (pageWidth - reportSize.width) / 2
        reportDate.draw(at: CGPoint(x: reportX, y: currentY), withAttributes: reportAttrs)
        currentY += 25
        
        // Separator Line
        drawSeparatorLine(context: context, y: currentY, fullWidth: true)
        currentY += 20
        
        return currentY
    }
    
    private func drawExecutiveSummary(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionHeader("EXECUTIVE SUMMARY", context: context, y: currentY)
        
        // Key Metrics - Professional Layout
        currentY = drawExecutiveSummaryTable(session: session, context: context, y: currentY)
        
        currentY += 15
        

        
        return currentY + 15
    }
    
    private func drawExecutiveSummaryTable(session: ResuscitationSession, context: CGContext, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Create summary table data
        let outcomeText = session.patientOutcome == .alive ? "ROSC ACHIEVED" :
                         session.patientOutcome == .death ? "NO ROSC" : "IN PROGRESS"
        
        let summaryData = [
            ("Total Duration:", session.formattedDuration),
            ("Total Events:", "\(session.eventCount)"),
            ("Patient Outcome:", outcomeText),
            ("Shocks Delivered:", "\(session.shockCount)"),
            ("Medications Given:", "\(session.medicationCount)")
        ]
        
        currentY = drawTwoColumnData(summaryData, context: context, y: currentY)
        
        return currentY
    }
    
    private func drawPatientInformation(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionHeader("PATIENT INFORMATION", context: context, y: currentY)
        
        // Since this is training data, show anonymized/simulation data
        let patientData = [
            ("Patient ID:", session.mode == .clinical ? "ANON-\(String(session.sessionID.uuidString.prefix(6)))" : "SIMULATED"),
            ("Case Type:", session.mode == .clinical ? "Clinical Case" : "Training Simulation"),
            ("Presenting Rhythm:", getInitialRhythm(from: session)),
            ("Final Status:", formatPatientOutcome(session.patientOutcome))
        ]
        
        currentY = drawTwoColumnData(patientData, context: context, y: currentY)
        
        return currentY + 15
    }
    
    private func drawSessionMetadata(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionHeader("SESSION DETAILS", context: context, y: currentY)
        
        let sessionData = [
            ("Session ID:", String(session.sessionID.uuidString.prefix(8)).uppercased()),
            ("Start Time:", formatDateTimeDetailed(session.startTime)),
            ("End Time:", formatDateTimeDetailed(session.endTime)),
            ("Training Mode:", session.mode.rawValue.capitalized),
            ("Report Generated:", formatDateTimeDetailed(Date()))
        ]
        
        currentY = drawTwoColumnData(sessionData, context: context, y: currentY)
        
        return currentY + 15
    }
    
    private func drawMultiSessionHeader(title: String, totalSessions: Int, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Main Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.title.withSize(24),
            .foregroundColor: colors.primary
        ]
        let titleSize = title.size(withAttributes: titleAttrs)
        let titleX = (pageWidth - titleSize.width) / 2
        title.draw(at: CGPoint(x: titleX, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 10
        
        // Session count
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.bodyBold,
            .foregroundColor: colors.accent
        ]
        let subtitle = "Total Sessions: \(totalSessions)"
        let subtitleSize = subtitle.size(withAttributes: subtitleAttrs)
        let subtitleX = (pageWidth - subtitleSize.width) / 2
        subtitle.draw(at: CGPoint(x: subtitleX, y: currentY), withAttributes: subtitleAttrs)
        currentY += subtitleSize.height + 5
        
        // Generation date
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.caption,
            .foregroundColor: colors.secondary
        ]
        let dateText = "Generated on \(formatDateTimeDetailed(Date()))"
        let dateSize = dateText.size(withAttributes: dateAttrs)
        let dateX = (pageWidth - dateSize.width) / 2
        dateText.draw(at: CGPoint(x: dateX, y: currentY), withAttributes: dateAttrs)
        currentY += dateSize.height + 20
        
        // Separator line
        drawSeparatorLine(context: context, y: currentY, fullWidth: true)
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
    
    private func drawPageHeader(title: String, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Add top spacing
        currentY += 10
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.sectionHeader,
            .foregroundColor: colors.primary
        ]
        
        let titleSize = title.size(withAttributes: titleAttrs)
        title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 8
        
        drawSeparatorLine(context: context, y: currentY, fullWidth: true)
        currentY += 25
        
        return currentY
    }
    
    private func drawDetailedEventTimeline(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        if session.events.isEmpty {
            let noEventsAttrs: [NSAttributedString.Key: Any] = [
                .font: fonts.body,
                .foregroundColor: colors.secondary
            ]
            "No events recorded in this session.".draw(at: CGPoint(x: margin, y: currentY), withAttributes: noEventsAttrs)
            return currentY + 30
        }
        
        // Add spacing before table
        currentY += 10
        
        // Timeline Table Header
        let headerBg = CGRect(x: margin, y: currentY, width: contentWidth, height: 25)
        context.setFillColor(colors.background.cgColor)
        context.fill(headerBg)
        
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.bodyBold,
            .foregroundColor: colors.primary
        ]
        
        "TIME".draw(at: CGPoint(x: margin + 8, y: currentY + 7), withAttributes: headerAttrs)
        "EVENT TYPE".draw(at: CGPoint(x: margin + 80, y: currentY + 7), withAttributes: headerAttrs)
        "DESCRIPTION".draw(at: CGPoint(x: margin + 200, y: currentY + 7), withAttributes: headerAttrs)
        "CLINICAL SIGNIFICANCE".draw(at: CGPoint(x: margin + 360, y: currentY + 7), withAttributes: headerAttrs)
        
        currentY += 35
        
        // Timeline Events
        let timeAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.monospace,
            .foregroundColor: colors.accent
        ]
        
        let eventAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.body,
            .foregroundColor: colors.primary
        ]
        
        let typeAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.bodyBold,
            .foregroundColor: colors.secondary
        ]
        
        for (index, event) in session.events.enumerated() {
            // Check for page break first
            if currentY > pageHeight - 120 {
                break
            }
            
            // Alternate row background with proper spacing
            let rowHeight: CGFloat = 20
            if index % 2 == 0 {
                let rowBg = CGRect(x: margin, y: currentY - 2, width: contentWidth, height: rowHeight)
                context.setFillColor(colors.background.withAlphaComponent(0.3).cgColor)
                context.fill(rowBg)
            }
            
            let timeText = formatRelativeTime(event.timestamp, startTime: session.startTime)
            let (eventType, description, significance) = getClinicalEventDetails(event)
            
            // Define column positions with better spacing
            let timeCol = margin + 10
            let typeCol = margin + 85
            let descCol = margin + 205
            let sigCol = margin + 365
            
            // Draw text with proper column spacing
            timeText.draw(at: CGPoint(x: timeCol, y: currentY + 2), withAttributes: timeAttrs)
            
            let truncatedType = eventType.count > 12 ? String(eventType.prefix(9)) + "..." : eventType
            truncatedType.draw(at: CGPoint(x: typeCol, y: currentY + 2), withAttributes: typeAttrs)
            
            let truncatedDesc = description.count > 20 ? String(description.prefix(17)) + "..." : description
            truncatedDesc.draw(at: CGPoint(x: descCol, y: currentY + 2), withAttributes: eventAttrs)
            
            let truncatedSig = significance.count > 15 ? String(significance.prefix(12)) + "..." : significance
            truncatedSig.draw(at: CGPoint(x: sigCol, y: currentY + 2), withAttributes: eventAttrs)
            
            currentY += rowHeight
        }
        
        return currentY + 30
    }
    
    private func drawQualityMetrics(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionHeader("QUALITY METRICS", context: context, y: currentY)
        
        // Response Times
        let firstCPRTime = getFirstCPRTime(from: session)
        let firstShockTime = getFirstShockTime(from: session)
        
        let metricsData = [
            ("Time to First CPR:", firstCPRTime ?? "Not recorded"),
            ("Time to First Shock:", firstShockTime ?? "No shocks delivered"),
            ("Total CPR Cycles:", "\(getCPRCycleCount(from: session))"),
            ("Average Cycle Duration:", getAverageCycleDuration(from: session)),
            ("Medication Compliance:", getMedicationCompliance(from: session)),
            ("Overall Quality Score:", calculateQualityScore(from: session))
        ]
        
        currentY = drawTwoColumnData(metricsData, context: context, y: currentY)
        
        return currentY + 15
    }
    
    private func drawMedicationAnalysis(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        let medications = getMedicationSummary(from: session)
        if medications.isEmpty {
            return currentY
        }
        
        currentY = drawSectionHeader("MEDICATION ANALYSIS", context: context, y: currentY)
        
        for (medication, count) in medications.sorted(by: { $0.key < $1.key }) {
            let dosageText = "\(count) dose\(count > 1 ? "s" : "") administered"
            let timing = getMedicationTiming(medication: medication, from: session)
            
            currentY = drawMedicationEntry(
                medication: medication,
                dosage: dosageText,
                timing: timing,
                context: context,
                y: currentY
            )
        }
        
        return currentY + 15
    }
    
    private func drawCPRQualityAnalysis(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        let cprCycles = getCPRCycleCount(from: session)
        if cprCycles == 0 {
            return currentY
        }
        
        currentY = drawSectionHeader("CPR QUALITY ANALYSIS", context: context, y: currentY)
        
        let cprData = [
            ("Total Cycles Performed:", "\(cprCycles)"),
            ("Average Cycle Duration:", getAverageCycleDuration(from: session)),
            ("Longest Cycle:", getLongestCycleDuration(from: session)),
            ("Shortest Cycle:", getShortestCycleDuration(from: session)),
            ("CPR Interruption Time:", getCPRInterruptionAnalysis(from: session)),
            ("Quality Assessment:", getCPRQualityAssessment(from: session))
        ]
        
        currentY = drawTwoColumnData(cprData, context: context, y: currentY)
        
        return currentY + 15
    }
        
    private func drawPageFooter(context: CGContext, pageRect: CGRect, pageNumber: Int) {
        let footerY = pageHeight - margin + 10
        
        // Footer separator
        drawSeparatorLine(context: context, y: footerY, fullWidth: true)
        
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.caption,
            .foregroundColor: colors.secondary
        ]
        
        // Page number on right
        let pageText = "Page \(pageNumber)"
        let pageSize = pageText.size(withAttributes: footerAttrs)
        pageText.draw(at: CGPoint(x: pageWidth - margin - pageSize.width, y: footerY + 8), withAttributes: footerAttrs)
        
        // Footer text on left
        let footerText = "ResApp - Resuscitation Documentation System"
        footerText.draw(at: CGPoint(x: margin, y: footerY + 8), withAttributes: footerAttrs)
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
        currentY = drawSectionHeader("SESSION OVERVIEW", context: context, y: currentY)
        
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
        
        currentY = drawSectionHeader("CLINICAL SUMMARY", context: context, y: currentY)
        
        // Create a 3-column layout for statistics
        let columnWidth = (pageRect.width - 140) / 3
        let startX: CGFloat = 70
        
        // Total Events
        currentY = drawStatBox("Total Events", value: "\(session.eventCount)", 
                              x: startX, y: currentY, width: columnWidth, context: context)
        
        // Shocks Delivered
        _ = drawStatBox("Shocks Delivered", value: "\(session.shockCount)", 
                       x: startX + columnWidth + 10, y: currentY - 60, width: columnWidth, context: context)
        
        // Medications Given
        _ = drawStatBox("Medications", value: "\(session.medicationCount)", 
                       x: startX + (columnWidth + 10) * 2, y: currentY - 60, width: columnWidth, context: context)
        
        return currentY + 20
    }
    
    // MARK: - Event Timeline Section
    private func drawEventTimeline(session: ResuscitationSession, context: CGContext, pageRect: CGRect, y: CGFloat) -> CGFloat {
        var currentY = y
        
        currentY = drawSectionHeader("EVENT TIMELINE", context: context, y: currentY)
        
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
        currentY = drawSectionHeader("MEDICATION SUMMARY", context: context, y: currentY)
        
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
        
        currentY = drawSectionHeader("CPR ANALYSIS", context: context, y: currentY)
        
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
    private func drawSectionHeader(_ title: String, context: CGContext, y: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: fonts.sectionHeader,
            .foregroundColor: colors.primary
        ]
        
        let size = title.size(withAttributes: attributes)
        
        // Clear any potential overlapping area
        let clearRect = CGRect(x: margin, y: y - 5, width: contentWidth, height: size.height + 25)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(clearRect)
        
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: attributes)
        
        // Professional underline with proper spacing
        context.setStrokeColor(colors.accent.cgColor)
        context.setLineWidth(2.0)
        context.move(to: CGPoint(x: margin, y: y + size.height + 5))
        context.addLine(to: CGPoint(x: margin + size.width, y: y + size.height + 5))
        context.strokePath()
        
        return y + size.height + 20
    }
    
    private func drawMetricBox(title: String, value: String, color: UIColor, x: CGFloat, y: CGFloat, width: CGFloat, context: CGContext) -> CGFloat {
        let boxHeight: CGFloat = 50
        let boxRect = CGRect(x: x, y: y, width: width, height: boxHeight)
        
        // Background with subtle border
        context.setFillColor(color.withAlphaComponent(0.05).cgColor)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(1.5)
        
        let cornerRadius: CGFloat = 4
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.drawPath(using: .fillStroke)
        
        // Value (prominent)
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.title,
            .foregroundColor: color
        ]
        let valueSize = value.size(withAttributes: valueAttrs)
        let valuePoint = CGPoint(
            x: x + (width - valueSize.width) / 2,
            y: y + 8
        )
        value.draw(at: valuePoint, withAttributes: valueAttrs)
        
        // Title (subtitle)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.caption,
            .foregroundColor: colors.secondary
        ]
        let titleSize = title.size(withAttributes: titleAttrs)
        let titlePoint = CGPoint(
            x: x + (width - titleSize.width) / 2,
            y: y + boxHeight - 15
        )
        title.draw(at: titlePoint, withAttributes: titleAttrs)
        
        return y + boxHeight + 10
    }
    
    private func drawTwoColumnData(_ data: [(String, String)], context: CGContext, y: CGFloat) -> CGFloat {
        var currentY = y
        let labelWidth: CGFloat = 170
        let valueX = margin + labelWidth + 20
        let rowHeight: CGFloat = 22
        
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.body,
            .foregroundColor: colors.secondary
        ]
        
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.bodyBold,
            .foregroundColor: colors.primary
        ]
        
        for (label, value) in data {
            // Clear background to prevent overlap
            let rowRect = CGRect(x: margin, y: currentY - 2, width: contentWidth, height: rowHeight)
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rowRect)
            
            // Draw with proper spacing
            let labelRect = CGRect(x: margin, y: currentY, width: labelWidth, height: 18)
            let valueRect = CGRect(x: valueX, y: currentY, width: contentWidth - labelWidth - 20, height: 18)
            
            label.draw(in: labelRect, withAttributes: labelAttrs)
            value.draw(in: valueRect, withAttributes: valueAttrs)
            currentY += rowHeight
        }
        
        return currentY + 10
    }
    
    private func drawMedicationEntry(medication: String, dosage: String, timing: String, context: CGContext, y: CGFloat) -> CGFloat {
        var currentY = y
        
        // Clear background area to prevent overlap
        let entryHeight: CGFloat = timing.isEmpty ? 45 : 65
        let clearRect = CGRect(x: margin, y: currentY - 2, width: contentWidth, height: entryHeight)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(clearRect)
        
        // Medication name - formal style
        let medAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.bodyBold,
            .foregroundColor: colors.primary
        ]
        
        medication.draw(at: CGPoint(x: margin + 15, y: currentY), withAttributes: medAttrs)
        currentY += 20
        
        // Dosage details
        let detailAttrs: [NSAttributedString.Key: Any] = [
            .font: fonts.body,
            .foregroundColor: colors.secondary
        ]
        
        "Dosage: \(dosage)".draw(at: CGPoint(x: margin + 25, y: currentY), withAttributes: detailAttrs)
        currentY += 18
        
        if !timing.isEmpty {
            "Administration Time: \(timing)".draw(at: CGPoint(x: margin + 25, y: currentY), withAttributes: detailAttrs)
            currentY += 18
        }
        
        return currentY + 12
    }
    
    private func drawSeparatorLine(context: CGContext, y: CGFloat, fullWidth: Bool = false) {
        let startX = fullWidth ? 0 : margin
        let endX = fullWidth ? pageWidth : pageWidth - margin
        
        context.setStrokeColor(colors.border.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: startX, y: y))
        context.addLine(to: CGPoint(x: endX, y: y))
        context.strokePath()
    }
    
    private func drawMultilineText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any], context: CGContext) -> CGFloat {
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        // Save context state
        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: 0, y: rect.maxY)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Set clipping to prevent text overflow
        context.clip(to: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        
        CTFrameDraw(frame, context)
        context.restoreGState()
        
        // Calculate actual height used
        let lines = CTFrameGetLines(frame)
        let lineCount = CFArrayGetCount(lines)
        let lineHeight: CGFloat = 18 // Consistent line height
        let totalHeight = CGFloat(lineCount) * lineHeight
        
        // Ensure minimum height to prevent overlap
        return max(totalHeight, 20)
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
    
    private func formatDateTimeDetailed(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a"
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
    
    // MARK: - Clinical Analysis Functions
    private func getInitialRhythm(from session: ResuscitationSession) -> String {
        for event in session.events {
            if case .checkRhythm(let rhythm) = event.type {
                return rhythm
            }
        }
        return "Not documented"
    }
    
    private func getClinicalEventDetails(_ event: ResuscitationEvent) -> (type: String, description: String, significance: String) {
        switch event.type {
        case .startCPR:
            return ("CPR", "CPR initiated", "Critical intervention")
        case .checkRhythm(let rhythm):
            return ("RHYTHM", "Rhythm: \(rhythm)", "Assessment")
        case .shockDelivered(let joules):
            return ("DEFIB", "Shock delivered: \(joules)J", "High priority")
        case .cprCycle(let duration):
            return ("CPR", "Cycle duration: \(duration)", "Quality metric")
        case .adrenalineFirst:
            return ("MEDICATION", "Adrenaline 1mg (1st)", "First-line treatment")
        case .adrenalineSecond(_):
            return ("MEDICATION", "Adrenaline 1mg (2nd)", "Standard protocol")
        case .adrenalineSubsequent(let dose, _):
            return ("MEDICATION", "Adrenaline 1mg (\(dose)th)", "Continued therapy")
        case .amiodarone(let dose):
            return ("MEDICATION", "Amiodarone (\(dose)th)", "Antiarrhythmic")
        case .startROSC:
            return ("ROSC", "ROSC achieved", "Successful outcome")
        case .patientOutcomeAlive:
            return ("OUTCOME", "Patient alive", "Positive outcome")
        case .patientOutcomeDeath:
            return ("OUTCOME", "Patient deceased", "Terminal outcome")
        case .medication(let med):
            return ("MEDICATION", med, "Therapeutic intervention")
        case .alert(let message):
            return ("ALERT", message, "System notification")
        case .other(let desc):
            return ("OTHER", desc, "Additional event")
        }
    }
    
    private func getFirstCPRTime(from session: ResuscitationSession) -> String? {
        for event in session.events {
            if case .startCPR = event.type {
                return formatRelativeTime(event.timestamp, startTime: session.startTime)
            }
        }
        return nil
    }
    
    private func getFirstShockTime(from session: ResuscitationSession) -> String? {
        for event in session.events {
            if case .shockDelivered(_) = event.type {
                return formatRelativeTime(event.timestamp, startTime: session.startTime)
            }
        }
        return nil
    }
    
    private func getCPRCycleCount(from session: ResuscitationSession) -> Int {
        return session.events.filter {
            if case .cprCycle(_) = $0.type { return true }
            return false
        }.count
    }
    
    private func getAverageCycleDuration(from session: ResuscitationSession) -> String {
        let cprCycles = session.events.filter {
            if case .cprCycle(_) = $0.type { return true }
            return false
        }
        
        guard !cprCycles.isEmpty else { return "No cycles recorded" }
        
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
        
        guard validCycles > 0 else { return "Unable to calculate" }
        
        let avgDuration = totalDuration / Double(validCycles)
        let avgMinutes = Int(avgDuration) / 60
        let avgSeconds = Int(avgDuration) % 60
        return String(format: "%02d:%02d", avgMinutes, avgSeconds)
    }
    
    private func getLongestCycleDuration(from session: ResuscitationSession) -> String {
        let durations = extractCycleDurations(from: session)
        return durations.isEmpty ? "N/A" : formatDuration(durations.max() ?? 0)
    }
    
    private func getShortestCycleDuration(from session: ResuscitationSession) -> String {
        let durations = extractCycleDurations(from: session)
        return durations.isEmpty ? "N/A" : formatDuration(durations.min() ?? 0)
    }
    
    private func extractCycleDurations(from session: ResuscitationSession) -> [TimeInterval] {
        var durations: [TimeInterval] = []
        
        for event in session.events {
            if case .cprCycle(let duration) = event.type {
                if let minutes = Double(duration.components(separatedBy: ":").first ?? "0"),
                   let seconds = Double(duration.components(separatedBy: ":").last ?? "0") {
                    durations.append(minutes * 60 + seconds)
                }
            }
        }
        
        return durations
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func getCPRInterruptionAnalysis(from session: ResuscitationSession) -> String {
        // This is a simplified analysis - could be more sophisticated
        let totalEvents = session.eventCount
        let cprEvents = getCPRCycleCount(from: session)
        
        if cprEvents == 0 { return "No CPR recorded" }
        if totalEvents <= cprEvents { return "Minimal interruptions" }
        
        let ratio = Double(cprEvents) / Double(totalEvents)
        if ratio > 0.7 { return "Good CPR continuity" }
        else if ratio > 0.5 { return "Moderate interruptions" }
        else { return "Frequent interruptions" }
    }
    
    private func getCPRQualityAssessment(from session: ResuscitationSession) -> String {
        let cycleCount = getCPRCycleCount(from: session)
        let sessionDuration = session.endTime.timeIntervalSince(session.startTime) / 60 // minutes
        
        if cycleCount == 0 { return "No assessment possible" }
        
        let cyclesPerMinute = Double(cycleCount) / sessionDuration
        
        if cyclesPerMinute >= 0.8 { return "Excellent quality" }
        else if cyclesPerMinute >= 0.6 { return "Good quality" }
        else if cyclesPerMinute >= 0.4 { return "Adequate quality" }
        else { return "Needs improvement" }
    }
    
    private func getMedicationCompliance(from session: ResuscitationSession) -> String {
        let medicationCount = session.medicationCount
        let sessionDurationMinutes = session.endTime.timeIntervalSince(session.startTime) / 60
        
        if sessionDurationMinutes < 3 { return "Session too short" }
        if medicationCount == 0 { return "No medications given" }
        
        // Basic compliance check - adrenaline should be given every 3-5 minutes
        let expectedDoses = max(1, Int(sessionDurationMinutes / 4))
        let compliance = Double(medicationCount) / Double(expectedDoses)
        
        if compliance >= 1.0 { return "Excellent compliance" }
        else if compliance >= 0.7 { return "Good compliance" }
        else if compliance >= 0.5 { return "Adequate compliance" }
        else { return "Below standard" }
    }
    
    private func calculateQualityScore(from session: ResuscitationSession) -> String {
        var score = 0
        var maxScore = 0
        
        // CPR Quality (25%)
        maxScore += 25
        let cprQuality = getCPRQualityAssessment(from: session)
        switch cprQuality {
        case "Excellent quality": score += 25
        case "Good quality": score += 20
        case "Adequate quality": score += 15
        default: score += 5
        }
        
        // Medication Compliance (25%)
        maxScore += 25
        let medCompliance = getMedicationCompliance(from: session)
        switch medCompliance {
        case "Excellent compliance": score += 25
        case "Good compliance": score += 20
        case "Adequate compliance": score += 15
        default: score += 5
        }
        
        // Response Time (25%)
        maxScore += 25
        if getFirstCPRTime(from: session) != nil {
            score += 20 // Good response if CPR was started
        }
        if getFirstShockTime(from: session) != nil {
            score += 5 // Additional points for defibrillation
        }
        
        // Documentation Quality (25%)
        maxScore += 25
        let eventCount = session.eventCount
        if eventCount > 10 { score += 25 }
        else if eventCount > 5 { score += 20 }
        else if eventCount > 2 { score += 15 }
        else { score += 5 }
        
        let percentage = (Double(score) / Double(maxScore)) * 100
        return String(format: "%.0f%%", percentage)
    }
    
    private func getMedicationTiming(medication: String, from session: ResuscitationSession) -> String {
        var timings: [String] = []
        
        for event in session.events {
            let isTargetMed = switch event.type {
            case .medication(let med): med == medication
            case .adrenalineFirst, .adrenalineSecond, .adrenalineSubsequent: medication.contains("Adrenaline")
            case .amiodarone: medication.contains("Amiodarone")
            default: false
            }
            
            if isTargetMed {
                timings.append(formatRelativeTime(event.timestamp, startTime: session.startTime))
            }
        }
        
        return timings.isEmpty ? "No timing data" : timings.joined(separator: ", ")
    }
} 