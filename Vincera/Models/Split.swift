//
//  Split.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

@Observable
final class Split: Codable, Identifiable, Hashable {
  var id: String
  var name: String
  var description: String
  var days: [Day]
  
  init(id: String, name: String, description: String, days: [Day]) {
    self.id = id
    self.name = name
    self.description = description
    self.days = days
  }
  
  init() {
    self.id = UUID().uuidString
    self.name = ""
    self.description = ""
    self.days = []
  }
  
  func clone() -> Split {
    return Split(id: UUID().uuidString, name: name, description: description, days: days.map { $0.clone() })
  }
  
  func cloneWithUUID() -> Split {
    return Split(id: id, name: name, description: description, days: days.map { $0.clone() })
  }
  
  func addDay() {
    days.append(Day("Day \(days.count + 1)"))
  }
  
  @MainActor
  func getVolume(_ eStore: ExerciseStore) -> [Volume] {
    var parts = BodyPart.allCases.map { Volume(bodyPart: $0, sets: 0) }
    
    let exercises = self.days.flatMap { $0.exercises.flatMap { $0 } }
    let listExercises = exercises.map { eStore.getExercise($0.listId) }
    
    for e in zip(exercises, listExercises) {
      guard let listExercise = e.1 else { continue }
      guard let part = BodyPart(rawValue: listExercise.bodyPart) else { continue }
      guard let index = parts.firstIndex(where: { $0.bodyPart == part }) else { continue }
      parts[index].sets += e.0.sets.count
    }
    
    return parts
  }
  
  @MainActor
  func isBuiltin() -> Bool {
    return VINCERA_SPLITS.contains(where: { $0.id == id })
  }
  
  func moveDay(from: IndexSet, to: Int) {
    days.move(fromOffsets: from, toOffset: to)
  }
  
  func deleteDay(at: IndexSet) {
    days.remove(atOffsets: at)
  }
}

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
}
