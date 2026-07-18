//
//  VectorDatabaseTests.swift
//  Vincera
//
//  Created by Matt Linder on 5/28/26.
//

import Testing
import Foundation
@testable import Vincera

struct VectorDatabaseTests {
    
    private func getWritableDBURL(cleanup: Bool = false) -> URL {
        let fileManager = FileManager.default
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dbURL = cachesURL.appendingPathComponent("test-embeddings.db")
        if cleanup { try? fileManager.removeItem(at: dbURL) }
        print("👉 Inspectable Database Path: \(dbURL.path)")
        return dbURL
    }
    
    @Test func testVectorEncode() async throws {
        guard let jsonData = exerciseString.data(using: .utf8) else { return }
        let exercise = try JSONDecoder().decode(ListExercise.self, from: jsonData)
        
        let encoder = VectorEncoder()
        try await encoder.prepareModel()
        // Encode the compiled semantic payload
        if let vec = encoder.encode(exercise.semanticPayload) {
            print("Successfully generated vector!")
            print("Vector Count: \(vec.count)")
            print("Vector Preview: \(vec.prefix(5))...")
            
            #expect(vec.count == VECTOR_DATABASE_DIMENSIONS)
        }
    }
    
    @Test func testEncodeAndInsertAllExercises() async throws {
        let dbURL = getWritableDBURL(cleanup: true)
        guard let db = VectorDatabase(url: dbURL) else {
            Issue.record("Failed to connect to writable database")
            return
        }
        
        try db.initializeDatabase()
        
        let start = Date()
        let (created, deleted) = try await db.fillExercises()
        let end = Date()
        
        print("Filled exercises in \(end.timeIntervalSince(start))s")
        
        #expect(created > 0)
        #expect(deleted == 0)
    }
    
    @Test func testFetchSimilarExercise() throws {
        let dbURL = getWritableDBURL()
        guard let db = VectorDatabase(url: dbURL) else {
            Issue.record("Failed to connect to writable database")
            return
        }
        
        let results = try db.fetchSimilar(exerciseId: "0") // bench press
        print(results.map({ $0.name }))
        #expect(!results.isEmpty)
    }
}

private let exerciseString = """
{
    "id": "103",
    "name": "Reverse Grip Barbell Curl",
    "description": "Light isolation exercise that targets the forearms and biceps. Great for building size in the arms.",
    "directions": ["Set up...", "Get into..."],
    "cues": ["Keep your torso stable..."],
    "image": "reverse-grip-barbell-curl",
    "videoUrl": "https://youtube.com/shorts/V0bwkiLlZVY",
    "bodyPart": "arms",
    "unitsOne": "Weight",
    "unitsTwo": "Reps",
    "primaryGroup": "forearms",
    "secondaryGroups": ["biceps"],
    "exerciseType": "isolation",
    "equipmentType": "barbell",
    "repsLow": 8,
    "repsHigh": 12,
    "stimulus": 8,
    "fatigue": 3
}
"""
