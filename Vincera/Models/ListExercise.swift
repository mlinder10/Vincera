//
//  ListExercise.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation
import SwiftUI

@Observable
final class ListExercise: Codable, Identifiable, Hashable {  
  var id: String
  var name: String
  var description: String
  var directions: [String]
  var cues: [String]
  var image: String
  var videoId: String
  var bodyPart: String
  var primaryGroup: String
  var secondaryGroups: [String]
  var exerciseType: String
  var equipmentType: String
  var repsLow: Int
  var repsHigh: Int
  
  init(id: String, name: String, description: String, directions: [String], cues: [String], image: String, videoId: String, bodyPart: String, primaryGroup: String, secondaryGroups: [String], exerciseType: String, equipmentType: String, repsLow: Int, repsHigh: Int) {
    self.id = id
    self.name = name
    self.description = description
    self.directions = directions
    self.cues = cues
    self.image = image
    self.videoId = videoId
    self.bodyPart = bodyPart
    self.primaryGroup = primaryGroup
    self.secondaryGroups = secondaryGroups
    self.exerciseType = exerciseType
    self.equipmentType = equipmentType
    self.repsLow = repsLow
    self.repsHigh = repsHigh
  }
  
  @MainActor
  static let UNKNOWN = ListExercise(
    id: "unknown",
    name: "Unknown",
    description: "",
    directions: [],
    cues: [],
    image: "",
    videoId: "",
    bodyPart: "",
    primaryGroup: "",
    secondaryGroups: [],
    exerciseType: "",
    equipmentType: "",
    repsLow: 0,
    repsHigh: 0
  )
}

struct RemoteListExercise: Codable {
  var id: String?
  var name: String?
  var description: String?
  var directions: [String]?
  var cues: [String]?
  var image: String?
  var videoId: String?
  var bodyPart: String?
  var primaryGroup: String?
  var secondaryGroups: [String]?
  var exerciseType: String?
  var equipmentType: String?
  var repsLow: Int?
  var repsHigh: Int?
  
  func toListExercise() -> ListExercise? {
    guard let id, let name, let primaryGroup, let exerciseType, let equipmentType, let bodyPart else {
      return nil
    }
    return ListExercise(
      id: id,
      name: name,
      description: description ?? "",
      directions: directions ?? [],
      cues: cues ?? [],
      image: image ?? "",
      videoId: videoId ?? "",
      bodyPart: bodyPart,
      primaryGroup: primaryGroup,
      secondaryGroups: secondaryGroups ?? [],
      exerciseType: exerciseType,
      equipmentType: equipmentType,
      repsLow: repsLow ?? 0,
      repsHigh: repsHigh ?? 0
    )
  }
}

extension Sequence<ListExercise> {
  func groupByPrimaryGroup() -> [String: [ListExercise]] {
    var dict = [String: [ListExercise]]()
    let groups = Set(self.map { $0.primaryGroup })
    for group in groups {
      dict.updateValue(self.filter { $0.primaryGroup == group}, forKey: group)
    }
    return dict
  }
}

enum BodyPart: String, Identifiable, CaseIterable, Codable {
  var id: String { self.rawValue }
  
  case chest = "chest"
  case arms = "arms"
  case back = "back"
  case shoulders = "shoulders"
  case legs = "legs"
  case calves = "calves"
  case abs = "abs"

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
}

enum MuscleGroup: String, Identifiable, CaseIterable, Codable {
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
}

enum EquipmentType: String, Identifiable, CaseIterable, Codable {
  var id: String { self.rawValue }
  
  case barbell = "barbell"
  case dumbbell = "dumbbell"
  case machine = "machine"
  case bodyWeight = "bodyweight"
  case cable = "cable"
}

enum ExerciseType: String, Identifiable, CaseIterable, Codable {
  var id: String { self.rawValue }
  
  case compound = "compound"
  case isolation = "isolation"
  case cardio = "cardio"
}
