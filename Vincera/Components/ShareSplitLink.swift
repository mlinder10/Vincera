//
//  ShareSplitLink.swift
//  Vincera
//
//  Created by Matt Linder on 2/28/25.
//

import SwiftUI
import UniformTypeIdentifiers

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
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        // For Messages, we can return a text description
        if activityType == .message {
            return "Check out my workout split: \(splitName)"
        }
        return nil // The actual file is provided by the URL
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return "Vincera Workout Split: \(splitName)"
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        thumbnailImageForActivityType activityType: UIActivity.ActivityType?,
        suggestedSize size: CGSize
    ) -> UIImage? {
        // You could return a custom thumbnail image here if you have one
        return nil
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return UTType.vinceraWorkoutSplit.identifier
    }
}
