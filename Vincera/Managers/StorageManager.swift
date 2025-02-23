//
//  FileManager.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

enum File: String {
    case splits = "splits.json"
    case days = "days.json"
    case workouts = "workouts.json"
    case splitMeta = "split-meta.json"
    case exercisesBase = "exercises.json"
    case exercisesRemote = "exercises-remote.json"
    case workoutMeta = "workout-meta.json"
    case exercisesMut = "exercises-mutable.json"
    case products = "products.json"
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
    static let shared = StorageManager()
    
    private init() {}
    
    private func getFile(_ file: File) -> URL? {
        if file == .exercisesBase { return Bundle.main.url(forResource: "exercises", withExtension: "json") }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(file.rawValue)
    }
    
    func read<T: Decodable>(_ path: File) throws -> T {
        guard let file = getFile(path) else { throw StorageError.invalidUrl }
        guard let  data = try? Data(contentsOf: file) else { throw StorageError.failedToRead }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else { throw StorageError.failedToDecode }
        return decoded
    }
    
    func write<T: Encodable>(_ path: File, _ data: T) throws {
        guard let file = getFile(path) else { throw StorageError.invalidUrl }
        guard let encoded = try? JSONEncoder().encode(data) else { throw StorageError.failedToEncode }
        do {
            try encoded.write(to: file)
        } catch {
            throw StorageError.failedToWrite
        }
    }
}
