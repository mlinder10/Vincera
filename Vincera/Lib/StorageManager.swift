//
//  StorageManager.swift
//  Vincera
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

enum File: String {
    case splitsV1 = "splits.json"
    case daysV1 = "days.json"
    case workoutsV1 = "workouts.json"
    case workoutsV2 = "days-v2.json"
    case survey = "survey.json"
    case splitsV2 = "splits-v2.json"
    case completedWorkoutsV2 = "workouts-v2.json"
    case activeWorkout = "active-workout.json"
    case splitMeta = "split-meta.json"
    case trackers = "trackers.json"
    case exercisesBase = "exercises.json"
    case exercisesRemote = "exercises-remote.json"
    case exercisesMut = "exercises-mutable.json"
}

enum StorageError: LocalizedError {
    case invalidUrl
    case failedToRead
    case failedToDecode
    case failedToEncode
    case failedToWrite
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl: "Invalid URL"
        case .failedToRead: "Failed to read file"
        case .failedToDecode: "Failed to decode data"
        case .failedToEncode: "Failed to encode data"
        case .failedToWrite: "Failed to write to file"
        }
    }
}

final class StorageManager: Sendable {
    private static let iCloudContainerID = "iCloud.com.vincera.vincera"
    private static let storageQueue = DispatchQueue(label: "com.vincera.storageQueue", qos: .userInitiated)
    
    private init() {}
    
    private static func getLocalURL(for file: File) -> URL? {
        if file == .exercisesBase { return Bundle.main.url(forResource: "exercises", withExtension: "json") }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(file.rawValue)
    }
    
    private static func getiCloudURL(for file: File) -> URL? {
        guard let url = FileManager.default.url(forUbiquityContainerIdentifier: iCloudContainerID) else {
            return nil
        }
        
        let documentsURL = url.appendingPathComponent("Documents")
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true)
        }
        
        return documentsURL.appendingPathComponent(file.rawValue)
    }
    
    static func read<T: Decodable>(_ file: File) throws -> T {
        let data = try readRaw(file)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw StorageError.failedToDecode
        }
    }
    
    static func readRaw(_ file: File) throws -> Data {
        guard let localURL = getLocalURL(for: file) else { throw StorageError.invalidUrl }
        let iCloudURL = getiCloudURL(for: file)
        
        let localWriteDate = try? localURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        let iCloudWriteDate = try? iCloudURL?.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        
        // Check if iCloud has a newer copy
        if let iCloudURL, let localWriteDate, let iCloudWriteDate, iCloudWriteDate > localWriteDate {
            
            // Check if file is downloaded. If not, request download and fallback to local for this frame.
            let values = try? iCloudURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            if values?.ubiquitousItemDownloadingStatus != .current {
                try? FileManager.default.startDownloadingUbiquitousItem(at: iCloudURL)
                // Fallback to local while iCloud downloads on the system level
                return try Data(contentsOf: localURL)
            }
            
            // Use FileCoordinator to read safely from iCloud
            var coordinatorError: NSError?
            var readData: Data?
            let coordinator = NSFileCoordinator()
            
            coordinator.coordinate(readingItemAt: iCloudURL, options: [], error: &coordinatorError) { url in
                readData = try? Data(contentsOf: url)
            }
            
            if let data = readData { return data }
        }
        
        do {
            return try Data(contentsOf: localURL)
        } catch {
            throw StorageError.failedToRead
        }
    }
    
    static func write<T: Encodable>(_ file: File, _ data: T) throws {
        do {
            let encoded = try JSONEncoder().encode(data)
            try writeRaw(file, encoded)
        } catch {
            throw StorageError.failedToEncode
        }
    }
    
    static func writeRaw(_ file: File, _ data: Data) throws {
        guard let localURL = getLocalURL(for: file) else { throw StorageError.invalidUrl }
        
        // 1. Instantly write locally
        do {
            try data.write(to: localURL, options: .atomic)
        } catch {
            throw StorageError.failedToWrite
        }
        
        // 2. Queue the iCloud write sequentially to prevent race conditions
        guard let iCloudURL = getiCloudURL(for: file) else { return }
        storageQueue.async {
            let coordinator = NSFileCoordinator()
            var coordinatorError: NSError?
            
            coordinator.coordinate(writingItemAt: iCloudURL, options: .forReplacing, error: &coordinatorError) { url in
                try? data.write(to: url, options: .atomic)
            }
        }
    }
}
