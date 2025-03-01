//
//  SplitSharing.swift
//  Vincera
//
//  Created by Arshia Eslami on 2/28/25.
//


import SwiftUI
import UniformTypeIdentifiers

// Define a custom UTType for split files
extension UTType {
    static var vinceraWorkoutSplit: UTType {
        UTType(exportedAs: "com.vincera.split")
    }
}


// CHCEK if using uncheked sendable is correct
class SplitSharingManager : @unchecked Sendable {

    static let shared = SplitSharingManager()
    private init() {}

    func exportSplit(_ split: Split) -> URL? {
        do {
            let data = try JSONEncoder().encode(split)
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("\(split.name).vincera")
            try data.write(to: fileURL)
            
            // Set the UTI for the file to ensure proper identification
            try (fileURL as NSURL).setResourceValue(
                UTType.vinceraWorkoutSplit.identifier,
                forKey: URLResourceKey.typeIdentifierKey
            )
            
            return fileURL
        } catch {
            print("Failed to export split: \(error)")
            return nil
        }
    }

    func importSplit(from url: URL) throws -> Split {
        let data = try Data(contentsOf: url)
        let split = try JSONDecoder().decode(Split.self, from: data)
        return split
    }
    
    func handleIncomingURL(_ url: URL) -> Split? {
        do {
            let split = try importSplit(from: url)
            return split
        } catch {
            print("Failed to import split: \(error)")
            return nil
        }
    }

    // TODO: Check this fucntion
    func shareSplit(from split: Split) {
        // Extract the values we need from the split object
        let splitName = split.name
        
        // Create a temporary copy of the split data
        guard let splitData = try? JSONEncoder().encode(split) else {
            print("Failed to encode split")
            return
        }
        
        // Run UI operations on the main thread to avoid data races
        // TODO: Check if this is correct
        DispatchQueue.main.async {
            do {
                // Create the file URL on the main thread
                let tempDir = FileManager.default.temporaryDirectory
                let fileURL = tempDir.appendingPathComponent("\(splitName).vincera")
                try splitData.write(to: fileURL)
                
                // Set the UTI for the file
                try (fileURL as NSURL).setResourceValue(
                    UTType.vinceraWorkoutSplit.identifier,
                    forKey: URLResourceKey.typeIdentifierKey
                )
                
                // Create metadata
                let metadata = UIActivityItemMetadata(splitName: splitName)
                
                // Create activity items
                let activityItems: [Any] = [fileURL, metadata]
                
                let activityViewController = UIActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: nil
                )
                
                // Explicitly include Messages in the activity types
                activityViewController.excludedActivityTypes = []
                
                // Get the root view controller and present the activity view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    // If presented in a sheet, find the correct presenter
                    if let presentedVC = rootViewController.presentedViewController {
                        presentedVC.present(activityViewController, animated: true)
                    } else {
                        rootViewController.present(activityViewController, animated: true)
                    }
                }
            } catch {
                print("Failed to share split: \(error)")
            }
        }
    }

    
}


// ShareSplitLink - A SwiftUI view that uses ShareLink (iOS 16+)
@available(iOS 16.0, *)
struct ShareSplitLink: View {
    let split: Split
    
    var body: some View {
        if let url = SplitSharingManager.shared.exportSplit(split) {
            ShareLink(
                item: url,  // This is a file URL, not a web URL with parameters
                preview: SharePreview(
                    "Workout Split: \(split.name)",
                    image: Image(systemName: "figure.strengthtraining.traditional")
                )
            )
        } else {
            Text("Unable to share")
                .foregroundColor(.red)
        }
    }
}

// Add this class to provide better metadata for sharing
// It can modify the thumbnail, the message, preview, etc.
class UIActivityItemMetadata: NSObject, UIActivityItemSource {
    // Store only the name from Split
    private let splitName: String
    
    init(splitName: String) {
        self.splitName = splitName
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Vincera Workout Split: \(splitName)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // For Messages, we can return a text description
        if activityType == .message {
            return "Check out my workout split: \(splitName)"
        }
        return nil // The actual file is provided by the URL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Vincera Workout Split: \(splitName)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        // You could return a custom thumbnail image here if you have one
        return nil
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.vinceraWorkoutSplit.identifier
    }
}
