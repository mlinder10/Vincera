//
//  VectorDatabase.swift
//  Vincera
//
//  Created by Matt Linder on 7/6/25.
//

import Libsql
import Foundation

let VECTOR_DATABASE_DIMENSIONS = 512

final class VectorDatabase {
    static let shared = VectorDatabase()
    
    private let conn: Connection
    
    private init() {
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("Critical OS Error: Documents directory could not be located.")
        }
        
        let url = documentsURL.appendingPathComponent("embeddings.db")
        
        do {
            let db = try Database(url.path)
            self.conn = try db.connect()
            try initializeDatabase()
            print("Successfully connected to libSQL at: \(url.path)")
        } catch {
            fatalError("Libsql initialization failed: \(error.localizedDescription)")
        }
    }
    
    init?(url: URL) {
        do {
            let db = try Database(url.path)
            self.conn = try db.connect()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // table management
    
    func initializeDatabase() throws {
        let _ = try conn.execute(
            """
                CREATE TABLE IF NOT EXISTS vnc_exercises (
                    id TEXT PRIMARY KEY NOT NULL,
                    name TEXT NOT NULL,
                    body_part TEXT NOT NULL,
                    primary_group TEXT NOT NULL,
                    exercise_type TEXT NOT NULL,
                    equipment_type TEXT NOT NULL,
                    vector F64_BLOB(\(VECTOR_DATABASE_DIMENSIONS)) NOT NULL
                )
            """
        )
    }
    
    func deleteDatabase() throws {
        let _ = try conn.execute("DELETE FROM vnc_exercises")
    }
    
    func fillExercises() async throws -> (Int, Int) {
        let exercises = ExerciseList.shared.exercises
        let rows = try conn.query("SELECT id FROM vnc_exercises")
        let rowIds = rows.compactMap({ try? $0.getString(0) })
        
        let toDelete = rowIds.filter { row in
            exercises[row] == nil
        }
        
        var rowsDeleted = 0
        if !toDelete.isEmpty {
            let deleteIds = "(\(toDelete.joined(separator: ", ")))"
            rowsDeleted = try conn.execute("DELETE FROM vnc_exercises WHERE id IN \(deleteIds)")
        }
        
        let toCreate = exercises.values.filter {
            !rowIds.contains($0.id)
        }
        
        var rowsCreated = 0
        if !toCreate.isEmpty {
            rowsCreated = try await insert(toCreate)
        }
        
        return (rowsCreated, rowsDeleted)
    }
    
    // core app logic
    
    private func formatEmbedding(_ embedding: [Double]) -> Data {
        // Convert [Double] to Data (little-endian) for blob storage
        embedding.withUnsafeBufferPointer { buffer in
            Data(buffer: UnsafeBufferPointer(
                start: UnsafeRawPointer(buffer.baseAddress)?.assumingMemoryBound(to: UInt8.self),
                count: buffer.count * MemoryLayout<Double>.size)
            )
        }
    }
    
    private func insert(_ exercises: [ListExercise]) async throws -> Int {
        var sql = """
            INSERT INTO vnc_exercises
                (id, name, body_part, primary_group, exercise_type, equipment_type, vector)
            VALUES
                
        """
        var params = [any ValueRepresentable]()
        
        let encoder = VectorEncoder()
        try await encoder.prepareModel()
        
        for e in exercises {
            guard let embedding = encoder.encode(e.semanticPayload) else { continue }
            
            let embeddingData = formatEmbedding(embedding)
            sql += "(?, ?, ?, ?, ?, ?, ?), "
            let newParams: [any ValueRepresentable] = [e.id, e.name, e.bodyPart, e.primaryGroup, e.exerciseType, e.equipmentType, embeddingData]
            params.append(contentsOf: newParams)
        }
        
        if params.isEmpty { return 0 }
        
        sql = String(sql.dropLast(2))
        
        return try conn.execute(sql, params)
    }
    
    func fetchSimilar(
        exerciseId id: String,
        count limit: Int = 5,
        filter: ExerciseList.Filter? = nil
    ) throws -> [ListExercise] {
        let vectorQuery = try conn.query("SELECT vector FROM vnc_exercises WHERE id = ?", [id])
        
        var vector: Data?
        for row in vectorQuery {
            vector = try? row.getData(0)
        }
        
        guard let vector else { return [] }
        
        let sql = """
            SELECT id
            FROM vnc_exercises
            WHERE id != ?
            \(buildFilterString(filter))
        
            ORDER BY vector_distance_cos(vector, ?)
            LIMIT ?
        """
        
        let parameters: [any ValueRepresentable] = [id, vector, limit]
        let rows = try conn.query(sql, parameters)
        
        return try rows.compactMap { ExerciseList.shared.getExercise(try $0.getString(0)) }
    }
    
    private func buildFilterString(_ filter: ExerciseList.Filter?) -> String {
        guard let filter else { return "" }
        var str = ""
        
        if !filter.bodyParts.isEmpty {
            str += "AND body_part IN (" + filter.bodyParts.map({ "'\($0.rawValue)'" }).joined(separator: ", ") + ") "
        }
        
        if !filter.exerciseTypes.isEmpty {
            str += "AND exercise_type IN (" + filter.exerciseTypes.map({ "'\($0.rawValue)'" }).joined(separator: ", ") + ") "
        }
        
        if !filter.equipmentTypes.isEmpty {
            str += "AND equipment_type IN (" + filter.equipmentTypes.map({ "'\($0.rawValue)'" }).joined(separator: ", ") + ") "
        }
        
        if !filter.search.isEmpty {
            str += "AND name LIKE '%\(filter.search)%' "
        }
        
        if !filter.hidden.isEmpty {
            str += "AND id NOT IN (" + filter.hidden.map({ "'\($0)'" }).joined(separator: ", ") + ") "
        }
        
        return str
    }
}
