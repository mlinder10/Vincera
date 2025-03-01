//
//  ShareManager.swift
//  Vincera
//
//  Created by Matt Linder on 2/28/25.
//

import UniformTypeIdentifiers
import SwiftUI

// Define a custom UTType for split files
extension UTType {
    static var vinceraWorkoutSplit: UTType {
        UTType(exportedAs: "com.vincera.split")
    }
}

final class SplitSharingManager {
    @MainActor static let shared = SplitSharingManager()
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
        split.id = UUID().uuidString
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
