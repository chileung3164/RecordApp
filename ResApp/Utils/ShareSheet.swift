import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create a temporary PDF file for sharing
        var shareItems: [Any] = []
        
        for item in items {
            if let data = item as? Data {
                // Create a temporary file URL for the PDF
                let tempURL = createTempPDFFile(data: data)
                shareItems.append(tempURL)
            } else {
                shareItems.append(item)
            }
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootView = windowScene.windows.first?.rootViewController?.view {
                popover.sourceView = rootView
            }
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
    
    private func createTempPDFFile(data: Data) -> URL {
        let fileName = "ResuscitationReport_\(ISO8601DateFormatter().string(from: Date())).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try? data.write(to: tempURL)
        return tempURL
    }
} 