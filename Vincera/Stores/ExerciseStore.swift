//
//  ExerciseStore.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

private let EXERCISE_LIST_URL = "https://vinceratraining.com/api/exercises"

@MainActor
final class ExerciseStore: ObservableObject {
  @Published var exercises: [ListExercise]
  
  init() {
    exercises = [ListExercise]()
    // try to get remote exercise list
    Task {
      if let remote = try? await fetchRemoteExercises() {
        await MainActor.run {
          exercises.append(contentsOf: remote)
        }
      }
      
      // if can't get list, try to get cached exercises
      if exercises.isEmpty {
        if let cached: [ListExercise] = try? StorageManager.shared.read(.exercisesRemote) {
          exercises.append(contentsOf: cached)
        }
      }
      // if can't ge either or no exercises cached, resort to base list
      if exercises.isEmpty {
        if let base: [ListExercise] = try? StorageManager.shared.read(.exercisesBase) {
          exercises.append(contentsOf: base)
        }
      }
      // user created exercises
      if let custom: [ListExercise] = try? StorageManager.shared.read(.exercisesMut) {
        await MainActor.run {
          exercises.append(contentsOf: custom)
        }
      }
    }
  }
  
  func getExercise(_ id: String) -> ListExercise? {
    return exercises.first { $0.id == id }
  }
  
  func createExercise(_ exercise: ListExercise) throws {
    exercises.insert(exercise, at: 0)
    let size = UUID().uuidString.count
    do {
      try StorageManager.shared.write(.exercisesMut, exercises.filter({ $0.id.count == size }))
    } catch {
      exercises.removeFirst()
      throw error
    }
  }
  
  func editExercise(_ exercise: ListExercise) throws {
    let size = UUID().uuidString.count
    guard exercise.id.count == size else { return }
    guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
    let original = exercises[index]
    exercises[index] = exercise
    do {
      try StorageManager.shared.write(.exercisesMut, exercises)
    } catch {
      exercises[index] = original
      throw error
    }
  }
  
  func deleteExercise(_ exercise: ListExercise) throws {
    let size = UUID().uuidString.count
    guard exercise.id.count == size else { return }
    guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
    exercises.remove(at: index)
    do {
      try StorageManager.shared.write(.exercisesMut, exercises)
    } catch {
      exercises.insert(exercise, at: index)
      throw error
    }
  }
  
  struct Filter {
    var search = ""
    var exerciseTypes = [ExerciseType]()
    var equipmentTypes = [EquipmentType]()
    var bodyParts = [BodyPart]()
    var hidden = [String]()
  }
  
  func getFiltered(_ filter: Filter) -> [ListExercise] {
    return exercises.filter { ex in
      (filter.search.isEmpty || ex.name.lowercased().contains(filter.search.lowercased())) &&
      (filter.exerciseTypes.isEmpty || filter.exerciseTypes.contains(where: { $0.rawValue == ex.exerciseType })) &&
      (filter.equipmentTypes.isEmpty || filter.equipmentTypes.contains(where: { $0.rawValue == ex.equipmentType })) &&
      (filter.bodyParts.isEmpty || filter.bodyParts.contains(where: { $0.rawValue == ex.bodyPart }))
    }
  }
  
  func fetchRemoteExercises() async throws -> [ListExercise] {
    guard let url = URL(string: EXERCISE_LIST_URL) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let decoded = try JSONDecoder().decode([RemoteListExercise].self, from: data)
    return decoded.compactMap { $0.toListExercise() }
  }
}
