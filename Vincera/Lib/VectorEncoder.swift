//
//  TextEmbedding.swift
//  Vincera
//
//  Created by Matt Linder on 5/28/26.
//

import Foundation
import NaturalLanguage

// 2. Vector Encoding Engine
class LocalVectorEncoder {
    private let embedding: NLEmbedding?

    init() {
        // Use Apple's built-in word embedding for English (falls back to undetermined if needed)
        if let en = NLEmbedding.wordEmbedding(for: .english) {
            self.embedding = en
        } else {
            self.embedding = NLEmbedding.wordEmbedding(for: .undetermined)
        }
    }

    /// Encodes text and safely shrinks it to a 64-dimension vector
    func encodeTo64Dimensions(text: String) -> [Double]? {
        guard let embedding = embedding else { return nil }

        // Tokenize the text into words
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var tokenRanges: [Range<String.Index>] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokenRanges.append(range)
            return true
        }

        var sumVector: [Double] = []
        var counted = 0

        for range in tokenRanges {
            let token = String(text[range]).lowercased()
            guard let vec = embedding.vector(for: token) else { continue }
            if sumVector.isEmpty {
                sumVector = vec
            } else {
                // Sum element-wise
                for i in 0..<min(sumVector.count, vec.count) {
                    sumVector[i] += vec[i]
                }
                // If vec is longer than current sumVector (shouldn't happen with fixed-size embeddings), align length
                if vec.count > sumVector.count {
                    sumVector.append(contentsOf: vec[sumVector.count...])
                }
            }
            counted += 1
        }

        guard counted > 0 else { return nil }

        // Average the vector
        let averaged = sumVector.map { $0 / Double(counted) }

        // Ensure we return exactly 64 dimensions: slice or pad with zeros
        if averaged.count >= 64 {
            return Array(averaged.prefix(64))
        } else {
            var padded = averaged
            padded.append(contentsOf: Array(repeating: 0.0, count: 64 - averaged.count))
            return padded
        }
    }
}

// 3. Put it all together
func processExerciseJSON() {
    
}
