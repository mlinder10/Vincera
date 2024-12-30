//
//  WorkoutStore.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

enum Timeframe: String, CaseIterable, Identifiable {
  var id: String { return self.rawValue }
  
  case week = "Week"
  case month = "Month"
  case year = "Year"
  case allTime = "All Time"
  
  var date: Date {
    return switch self {
    case .week: Date(timeIntervalSinceNow: -1 * 60 * 60 * 24 * 7)
    case .month: Date(timeIntervalSinceNow: -1 * 60 * 60 * 24 * 30)
    case .year: Date(timeIntervalSinceNow: -1 * 60 * 60 * 24 * 365)
    case .allTime: Date(timeIntervalSince1970: 0)
    }
  }
}

struct TimerData {
  var show: Bool = false
  var duration: Int = 60
  var initialDuration: Int = 60
  var isPaused: Bool = true
  var publisher = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
  
  mutating func togglePause() {
    isPaused.toggle()
  }
  
  mutating func reset() {
    duration = initialDuration
    isPaused = true
  }
  
  func getPercentage() -> Double {
    return Double(duration) / Double(initialDuration)
  }
  
  mutating func handleChange(_: Int, _ new: Int) {
    duration = new
    isPaused = true
  }
  
  @MainActor
  mutating func handleCount(_: Any) {
    if !isPaused { duration = duration - 1 }
    if duration == 0 { handleZero() }
  }
  
  @MainActor
  private mutating func handleZero() {
    isPaused = true
    // TODO: alarm
    Haptics.shared.play(.heavy)
  }
}

@MainActor
final class WorkoutStore: ObservableObject {
  @Published var workouts: [Workout]
  @Published var active: Workout? = nil
  @Published var meta: WorkoutMeta
  @Published var timer = TimerData()
  
  init() {
    let workouts: [Workout]? = try? StorageManager.shared.read(.workouts)
    self.workouts = workouts ?? []
    let meta: WorkoutMeta? = try? StorageManager.shared.read(.workoutMeta)
    self.meta = meta ?? WorkoutMeta()
  }
  
  func createWorkout(_ workout: Workout) throws {
    workouts.insert(workout, at: 0)
    do {
      try StorageManager.shared.write(.workouts, workouts)
    } catch {
      workouts.removeFirst()
      throw error
    }
  }
  
  func editWorkout(_ workout: Workout) throws {
    guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
    let original = workouts[index]
    workouts[index] = workout
    do {
      try StorageManager.shared.write(.workouts, workouts)
    } catch {
      workouts[index] = original
      throw error
    }
  }
  
  func deleteWorkout(_ workout: Workout) throws {
    guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
    workouts.remove(at: index)
    do {
      try StorageManager.shared.write(.workouts, workouts)
    } catch {
      workouts.insert(workout, at: index)
      throw error
    }
  }
  
  func saveAllTrackers(_ trackers: [PRTracker]) throws {
    let original = meta.prs
    meta.prs = trackers
    do {
      try StorageManager.shared.write(.workoutMeta, meta)
    } catch {
      meta.prs = original
      throw error
    }
  }
  
  func createPrTracker(_ tracker: PRTracker) throws {
    if meta.prs.contains(tracker) { return }
    meta.prs.append(tracker)
    do {
      try StorageManager.shared.write(.workoutMeta, meta)
    } catch {
      meta.prs.removeLast()
      throw error
    }
  }
  
  func editPrTracker(_ tracker: PRTracker) throws {
    if meta.prs.contains(tracker) { return }
    guard let index = meta.prs.firstIndex(where: { $0 == tracker }) else { return }
    let original = meta.prs[index]
    meta.prs[index] = tracker
    do {
      try StorageManager.shared.write(.workoutMeta, meta)
    } catch {
      meta.prs[index] = original
      throw error
    }
  }
  
  func deletePrTracker(_ tracker: PRTracker) throws {
    guard let index = meta.prs.firstIndex(where: { $0 == tracker }) else { return }
    meta.prs.remove(at: index)
    do {
      try StorageManager.shared.write(.workoutMeta, meta)
    } catch {
      meta.prs.insert(tracker, at: index)
      throw error
    }
  }
  
  func startWorkout(_ day: Day? = nil) throws {
    guard active == nil else { throw VinceraError.existingWorkout }
    HealthManager.shared.startWorkout()
    active = Workout(day)
    timer = TimerData()
  }
  
  func cancelWorkout() {
    self.active = nil
  }
  
  func endWorkout() throws {
    guard let active, active.isValid() else {
      throw VinceraError.invalidWorkout
    }
    active.end = Date()
    try createWorkout(active)
    HealthManager.shared.endWorkout()
    self.active = nil
  }
  
  func getFiltered(_ search: String, _ timeframe: Timeframe) -> [Workout] {
    return getWorkouts().filter { search.isEmpty || $0.name.contains(search) }
  }

  func getPrs(timeframe: Timeframe = .allTime) -> [(PRTracker, Exercise?)] {
    return meta.prs.map { tracker in
      (tracker, getWorkouts(timeframe: timeframe)
        .flatMap({ $0.exercises.flattened().filter({ $0.listId == tracker.listId }) })
        .compactMap({ $0.maxValue(for: tracker.type) == nil ? nil : $0 })
        .sorted(by: { ($0.maxValue(for: tracker.type) ?? 0) > ($1.maxValue(for: tracker.type) ?? 0) })
        .first
      )
    }
  }
  
  func getWorkouts(timeframe: Timeframe = .allTime) -> [Workout] {
    var workouts = [Workout]()
    for w in self.workouts {
      if w.start < timeframe.date { break }
      workouts.append(w)
    }
    return workouts
  }
  
  func getVolume(_ eStore: ExerciseStore, timeframe: Timeframe = .allTime) -> [Volume] {
    var parts = BodyPart.allCases.map { Volume(bodyPart: $0, sets: 0) }
    
    let exercises = getWorkouts(timeframe: timeframe).flatMap { $0.exercises.flatMap { $0 } }
    let listExercises = exercises.map { eStore.getExercise($0.listId) }
    
    for e in zip(exercises, listExercises) {
      guard let listExercise = e.1 else { continue }
      guard let part = BodyPart(rawValue: listExercise.bodyPart) else { continue }
      guard let index = parts.firstIndex(where: { $0.bodyPart == part }) else { continue }
      parts[index].sets += e.0.sets.count
    }
    
    return parts
  }
  
  func getPreviousExercises(listIds: [String], workoutId: String? = nil) -> [Exercise] {
    var exercises = [Exercise]()
    
    var start = workoutId == nil ? true : false
    for w in workouts {
      if !start && w.id == workoutId { start = true; continue }
      if !start { continue }
      for e in w.exercises.flattened() {
        if !listIds.contains(e.listId) { continue }
        if exercises.contains(where: { $0.id == e.id }) { continue }
        exercises.append(e)
        if exercises.count == listIds.count { return exercises }
      }
    }
    
    return exercises
  }
  
  func lbToKg() throws {
    if meta.units == .metric { return }
    meta.units = .metric
    do {
      try StorageManager.shared.write(.workoutMeta, meta)
    } catch {
      meta.units = .imperial
      throw error
    }
    workouts.forEach {
      $0.exercises.flattened().forEach { ex in
        if ex.unitOne == .weight {
          ex.sets.forEach { $0.valueOne = $0.valueOne != nil ? $0.valueOne! / 2.2 : nil }
        }
        if ex.unitTwo == .weight {
          ex.sets.forEach { $0.valueTwo = $0.valueTwo != nil ? $0.valueTwo! / 2.2 : nil }
        }
      }
    }
  }
  
  func kgToLb() throws {
    if meta.units == .imperial { return }
    meta.units = .imperial
    do {
      try StorageManager.shared.write(.workoutMeta, meta)
    } catch {
      meta.units = .metric
      throw error
    }
    workouts.forEach {
      $0.exercises.flattened().forEach { ex in
        if ex.unitOne == .weight {
          ex.sets.forEach { $0.valueOne = $0.valueOne != nil ? $0.valueOne! * 2.2 : nil }
        }
        if ex.unitTwo == .weight {
          ex.sets.forEach { $0.valueTwo = $0.valueTwo != nil ? $0.valueTwo! * 2.2 : nil }
        }
      }
    }
  }
}


enum UnitSystem: String, Codable, CaseIterable, Identifiable {
  var id: Self { self }
  
  case metric = "Kg"
  case imperial = "Lbs"
}

@Observable
final class WorkoutMeta: Codable, Hashable {
  var prs: [PRTracker]
  var units: UnitSystem
  
  init(prs: [PRTracker], units: UnitSystem) {
    self.prs = prs
    self.units = units
  }
  
  init() {
    self.prs = [PRTracker]()
    self.units = .imperial
  }
}

struct PRTracker: Codable, Hashable, Identifiable {
  var id = UUID().uuidString
  var listId: String
  var type: ExerciseUnit
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(listId)
    hasher.combine(type)
  }
  
  static func == (lhs: PRTracker, rhs: PRTracker) -> Bool {
    return lhs.listId == rhs.listId && lhs.type == rhs.type
  }
}
