//
//  FileManager.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

enum File: String {
    case splitsV1 = "splits.json"
    case daysV1 = "days.json"
    case workoutsV1 = "workouts.json"
    
    // current
    case splitsV2 = "splits-v2.json"
    case workoutsV2 = "days-v2.json"
    case completedWorkoutsV2 = "workouts-v2.json"
    case activeWorkout = "active-workout.json"
    
    case splitMeta = "split-meta.json"
    case trackers = "trackers.json"
    
    case exercisesBase = "exercises.json"
    case exercisesRemote = "exercises-remote.json"
    case exercisesMut = "exercises-mutable.json"
    
    case meals = "meals.json"
    case consumedMeals = "consumed-meals.json"
    case ingredientsBase = "ingredients.json"
    case ingredientsRemote = "ingredients-remote.json"
    case ingredientsMut = "ingredients-mutable.json"
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
    private init() {}
    
    private static func getFile(_ file: File) -> URL? {
        if file == .exercisesBase { return Bundle.main.url(forResource: "exercises", withExtension: "json") }
        else if file == .ingredientsBase { return Bundle.main.url(forResource: "ingredients", withExtension: "json") }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(file.rawValue)
    }
    
    static func read<T: Decodable>(_ path: File) throws -> T {
        guard let file = getFile(path) else { throw StorageError.invalidUrl }
        let  data = try Data(contentsOf: file)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    static func write<T: Encodable>(_ path: File, _ data: T) throws {
        guard let file = getFile(path) else { throw StorageError.invalidUrl }
        let encoded = try JSONEncoder().encode(data)
        try encoded.write(to: file)
    }
}
