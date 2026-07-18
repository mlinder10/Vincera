//
//  Shared.swift
//  Vincera
//
//  Created by Matt Linder on 7/16/26.
//

import SwiftUI

struct Volume: Identifiable {
    let id = UUID().uuidString
    let bodyPart: BodyPart
    var sets: Int
}

extension Array<Volume> {
    func average(_ bodyPart: BodyPart) -> Int {
        guard let target = self.first(where: { $0.bodyPart == bodyPart }) else {
            return 0
        }
        let total = self.reduce(0) { $0 + $1.sets }
        if total == 0 { return 0 }
        return (target.sets * 100) / total
    }
    
    func sortedByAvg() -> [Volume] {
        return self.sorted { self.average($0.bodyPart) > self.average($1.bodyPart) }
    }
    
    func joined() -> [Volume] {
        var result = [Volume]()
        
        for element in self {
            if let idx = result.firstIndex(where: { $0.bodyPart == element.bodyPart }) {
                result[idx].sets += element.sets
            } else {
                result.append(element)
            }
        }
        
        return result
    }
}

enum SetType: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    var letter: String {
        switch self {
        case .normal: "N"
        case .myo: "M"
        case .drop: "D"
        case .warmup: "W"
        case .cooldown: "C"
        }
    }
    var color: Color {
        return switch self {
        case .normal: .gray
        case .myo: .red
        case .drop: .purple
        case .warmup: .orange
        case .cooldown: .blue
        }
    }
    
    case normal = "normal"
    case myo = "myo"
    case drop = "drop"
    case warmup = "warmup"
    case cooldown = "cooldown"
    
    static func fromLetter(_ value: String) -> SetType? {
        switch value {
        case "N": return .normal
        case "M": return .myo
        case "D": return .drop
        case "W": return .warmup
        case "C": return .cooldown
        default: return nil
        }
    }
}

enum SetValueSelector {
    case one, two
}
