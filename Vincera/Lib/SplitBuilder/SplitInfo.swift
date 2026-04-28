//
//  SplitInfo.swift
//  Vincera
//
//  Created by Matt Linder on 4/22/26.
//

import Foundation

struct SplitInfo {
    let sex: Sex
    let days: Days
    let goal: Goal
    let focus: [MuscleGroup]
    let equipment: [EquipmentType]
    
    enum Sex: String, CaseIterable, Identifiable {
        var id: Self { self }
        case male = "Male"
        case female = "Female"
    }

    enum Days: String, CaseIterable, Identifiable {
        var id: Self { self }
        case one = "One"
        case two = "Two"
        case three = "Three"
        case four = "Four"
        case five = "Five"
        case six = "Six"
        case seven = "Seven"
        
        var baseName: String {
            return switch self {
            case .one: "Full Body"
            case .two: "Full Body"
            case .three: "Full Body / Upper Lower"
            case .four: "Upper Lower"
            case .five: "Upper Lower / Push Pull Legs"
            case .six: "Push Pull Legs"
            case .seven: "Push Pull Legs"
            }
        }
        
        var descriptionBase: String {
            return switch self {
            case .one: "One day split"
            case .two: "Two day split"
            case .three: "Three day split"
            case .four: "Four day split"
            case .five: "Five day split"
            case .six: "Six day split"
            case .seven: "Seven day split"
            }
        }
    }
    
    enum Goal: String, CaseIterable, Identifiable {
        var id: Self { self }
        case size = "Size"
        case strength = "Strength"
        case weightLoss = "Weight Loss"
        
        var goalName: String {
            return switch self {
            case .size: " - Size"
            case .strength: " - Strength"
            case .weightLoss: " - Weight Loss"
            }
        }
    }
}

extension Array<MuscleGroup> {
    var focusDescription: String {
        if count == 0 { return "" }
        return " with " + self.map({ $0.rawValue }).joined(separator: ", ") + " emphasis"
    }
}

extension Array<EquipmentType> {
    var equipmentDescription: String {
        if count == 0 { return "" }
        return " using " + self.map({ $0.rawValue }).joined(separator: ", ")
    }
}
