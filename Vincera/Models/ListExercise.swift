//
//  ListExercise.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation
import SwiftUI

let CUSTOM_EXERCISE_PREFIX = "custom-"

struct ListExercise: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let description: String
    let directions: [String]
    let cues: [String]
    let image: String
    let videoUrl: String
    let bodyPart: String
    let primaryGroup: String
    let secondaryGroups: [String]
    let exerciseType: String
    let equipmentType: String
    let unitsOne: ExerciseUnit
    let unitsTwo: ExerciseUnit
    let repsLow: Int
    let repsHigh: Int
    let stimulus: Int
    let fatigue: Int
    var isCustom: Bool { id.hasPrefix(CUSTOM_EXERCISE_PREFIX) }
    
    init(
        id: String,
        name: String,
        description: String,
        directions: [String],
        cues: [String],
        image: String,
        videoUrl: String,
        bodyPart: String,
        primaryGroup: String,
        secondaryGroups: [String],
        exerciseType: String,
        equipmentType: String,
        unitsOne: ExerciseUnit,
        unitsTwo: ExerciseUnit,
        repsLow: Int,
        repsHigh: Int,
        stimulus: Int,
        fatigue: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.directions = directions
        self.cues = cues
        self.image = image
        self.videoUrl = videoUrl
        self.bodyPart = bodyPart
        self.primaryGroup = primaryGroup
        self.secondaryGroups = secondaryGroups
        self.exerciseType = exerciseType
        self.equipmentType = equipmentType
        self.unitsOne = unitsOne
        self.unitsTwo = unitsTwo
        self.repsLow = repsLow
        self.repsHigh = repsHigh
        self.stimulus = stimulus
        self.fatigue = fatigue
    }
    
    static let UNKNOWN = ListExercise(
        id: "unknown",
        name: "Unknown",
        description: "",
        directions: [],
        cues: [],
        image: "",
        videoUrl: "",
        bodyPart: "",
        primaryGroup: "",
        secondaryGroups: [],
        exerciseType: "",
        equipmentType: "",
        unitsOne: .weight,
        unitsTwo: .reps,
        repsLow: 0,
        repsHigh: 0,
        stimulus: 1,
        fatigue: 1
    )
}

struct RemoteListExercise: Codable, Sendable {
    let id: String?
    let name: String?
    let description: String?
    let directions: [String]?
    let cues: [String]?
    let image: String?
    let videoUrl: String?
    let bodyPart: String?
    let primaryGroup: String?
    let secondaryGroups: [String]?
    let exerciseType: String?
    let equipmentType: String?
    let unitsOne: ExerciseUnit?
    let unitsTwo: ExerciseUnit?
    let repsLow: Int?
    let repsHigh: Int?
    let stimulus: Int?
    let fatigue: Int?
    
    func toListExercise() -> ListExercise? {
        guard let id, let name, let primaryGroup, let exerciseType, let equipmentType,
              let bodyPart, let unitsOne, let unitsTwo else {
            return nil
        }
        return ListExercise(
            id: id,
            name: name,
            description: description ?? "",
            directions: directions ?? [],
            cues: cues ?? [],
            image: image ?? "",
            videoUrl: videoUrl ?? "",
            bodyPart: bodyPart,
            primaryGroup: primaryGroup,
            secondaryGroups: secondaryGroups ?? [],
            exerciseType: exerciseType,
            equipmentType: equipmentType,
            unitsOne: unitsOne,
            unitsTwo: unitsTwo,
            repsLow: repsLow ?? 0,
            repsHigh: repsHigh ?? 0,
            stimulus: stimulus ?? 1,
            fatigue: fatigue ?? 1
        )
    }
}

extension Dictionary<String, ListExercise> {
    func groupByPrimaryGroup() -> [String: [ListExercise]] {
        var dict = [String: [ListExercise]]()
        for (_, value) in self {
            if dict[value.primaryGroup] != nil {
                dict[value.primaryGroup]?.append(value)
            } else {
                dict[value.primaryGroup] = [value]
            }
        }
        for (key, _) in dict {
            dict[key] = dict[key]?.sorted(by: { $0.name < $1.name })
        }
        return dict
    }
}

enum BodyPart: String, StringRepresentable, Identifiable, CaseIterable, Codable {
    var id: String { self.rawValue }
    
    case chest = "chest"
    case arms = "arms"
    case back = "back"
    case shoulders = "shoulders"
    case legs = "legs"
    case calves = "calves"
    case abs = "abs"
    
    var string: String { self.rawValue.capitalized }
    
    var color: Color {
        switch self {
        case .chest: .red
        case .arms: .orange
        case .back: .yellow
        case .shoulders: .green
        case .legs: .blue
        case .calves: .purple
        case .abs: .pink
        }
    }
    
    func applicableMuscleGroups() -> [MuscleGroup] {
        switch self {
        case .arms: [.bis, .tris]
        case .back: [.lats, .erectors, .rhomboids]
        case .shoulders: [.frontDelts, .rearDelts, .sideDelts, .traps]
        case .abs: [.abs, .obliques]
        case .legs: [.quads, .hams, .glutes, .adductors, .abductors, .gastrocnemius, .soleus]
        case .calves: [.soleus, .gastrocnemius]
        case .chest: [.pecs]
        }
    }
}

enum MuscleGroup: String, StringRepresentable, Identifiable, CaseIterable, Codable {
    var id: String { self.rawValue }
    
    case pecs = "pectorals"
    case bis = "biceps"
    case tris = "triceps"
    case sideDelts = "side deltoids"
    case frontDelts = "front deltoids"
    case rearDelts = "rear deltoids"
    case traps = "trapezius"
    case rhomboids = "rhomboids"
    case lats = "lats"
    case erectors = "erector spinae"
    case obliques = "obliques"
    case abs = "abdominals"
    case glutes = "glutes"
    case hams = "hamstrings"
    case quads = "quadriceps"
    case adductors = "adductors"
    case abductors = "abductors"
    case gastrocnemius = "gastrocnemius"
    case soleus = "soleus"
    
    var string: String { self.rawValue.capitalized }
}

enum EquipmentType: String, StringRepresentable, Identifiable, CaseIterable, Codable {
    var id: String { self.rawValue }
    
    case barbell = "barbell"
    case dumbbell = "dumbbell"
    case machine = "machine"
    case bodyWeight = "bodyweight"
    case cable = "cable"
    case kettlebell = "kettlebell"
    
    var string: String { self.rawValue.split(separator: "-").map({ $0.capitalized }).joined(separator: " ") }
}

enum ExerciseType: String, StringRepresentable, Identifiable, CaseIterable, Codable {
    var id: String { self.rawValue }
    
    case compound = "compound"
    case isolation = "isolation"
    case isometric = "isometric"
    case cardio = "cardio"
    
    var string: String { self.rawValue.capitalized }
}

enum ExerciseUnit: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    var compressed: String {
        switch self {
        case .reps: "r"
        case .weight: "w"
        case .weightPlus: "p"
        case .time: "t"
        case .distance: "d"
        }
    }
    var icon: String {
        switch self {
        case .reps: "number"
        case .weight: "scalemass.fill"
        case .weightPlus: "scalemass.fill"
        case .time: "clock.fill"
        case .distance: "ruler.fill"
        }
    }
    
    static func fromCompressed(_ compressed: String) -> ExerciseUnit? {
        switch compressed {
        case "r": return .reps
        case "w": return .weight
        case "p": return .weightPlus
        case "t": return .time
        case "d": return .distance
        default: return nil
        }
    }
    
    case reps = "Reps"
    case weight = "Weight"
    case weightPlus = "Weight(+)"
    case time = "Time"
    case distance = "Distance"
}
