//
//  VectorEncoder.swift
//  Vincera
//
//  Created by Matt Linder on 5/28/26.
//

import Foundation
import NaturalLanguage

extension ListExercise {
    var semanticPayload: String {
        let muscleGroups = primaryGroup + (secondaryGroups.isEmpty ? "" : ", " + secondaryGroups.joined(separator: ", "))
        
        let boostedMuscleGroups = Array(repeating: muscleGroups, count: 5)
        let boostedBodyParts = Array(repeating: self.bodyPart, count: 5)
        let boostedIsCardio = Array(repeating: self.exerciseType == "cardio" ? "Cardio" : "Weights", count: 1)
        let boostedExerciseType = Array(repeating: self.exerciseType, count: 1)
        let boostedEquipmentType = Array(repeating: self.equipmentType, count: 1)
        
        return """
        1. \(boostedMuscleGroups.joined(separator: " | ")). \
        2. \(boostedBodyParts.joined(separator: " | ")). \
        3. \(boostedIsCardio.joined(separator: " | ")). \
        4. \(boostedExerciseType.joined(separator: " | ")). \
        5. \(boostedEquipmentType.joined(separator: " | ")).
        """
    }
}

final class VectorEncoder {
    private var embeddingModel: NLContextualEmbedding?
    
    init() {
        self.embeddingModel = NLContextualEmbedding(language: .english)
    }
    
    func prepareModel() async throws {
        try self.embeddingModel?.load()
    }
    
    func encode(_ text: String) -> [Double]? {
        guard let model = embeddingModel else { return nil }
        
        do {
            let result = try model.embeddingResult(for: text, language: .english)
            var rawVector = [Double]()
            
            result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, _ in
                rawVector = vector
                return false // Return false to stop enumeration immediately
            }
            
            return rawVector.isEmpty ? nil : rawVector
        } catch {
            print("Encoding error: \(error)")
            return nil
        }
    }
}
