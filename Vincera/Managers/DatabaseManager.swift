//
//  DatabaseManager.swift
//  Vincera
//
//  Created by Matt Linder on 7/6/25.
//

import Libsql
import Foundation

enum DatabaseError: LocalizedError {
    case connectionFailed
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed: "Failed to connect to the database"
        }
    }
}

final class DatabaseManager {
    @MainActor
    static let shared = DatabaseManager()
    private let conn: Connection?
    
    private init() {
        guard let url = Bundle.main.url(forResource: "weights", withExtension: "db") else {
            self.conn = nil
            return
        }
        do {
            let db = try Database(url.path)
            self.conn = try db.connect()
        } catch {
            print(error.localizedDescription)
            self.conn = nil
        }
    }
    
    @MainActor
    func fetchSimilar(
        exerciseId id: String,
        count limit: Int = 5,
        filter: ExerciseList.Filter? = nil
    ) throws -> [ListExercise] {
        guard let conn else { throw DatabaseError.connectionFailed }
        let rows = try conn.query(
        """
            SELECT id
            FROM vnc_exercises
            WHERE id != '\(id)'
            \(buildFilterString(filter))
        
            ORDER BY vector_distance_cos(
              vector,
              vector32((SELECT vector FROM vnc_exercises WHERE id = '\(id)'))
            )
            LIMIT \(limit)
        """
        )
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
