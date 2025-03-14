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
    
    func startWorkout(_ day: Day? = nil) throws {
        guard active == nil else { throw VinceraError.existingWorkout }
        DispatchQueue.main.async {
            HealthManager.shared.startWorkout()
        }
        active = Workout(day)
        timer = TimerData()
    }
    
    func cancelWorkout() {
        timer.reset()
        self.active = nil
    }
    
    @MainActor
    func endWorkout() throws {
        guard let active, active.isValid() else {
            throw VinceraError.invalidWorkout
        }
        timer.reset()
        active.end = Date()
        try createWorkout(active)
        DispatchQueue.main.async {
            HealthManager.shared.endWorkout()
            self.active = nil
        }
    }
    
    func getFiltered(_ search: String, _ timeframe: Timeframe) -> [Workout] {
        return getWorkouts(timeframe: timeframe).filter { search.isEmpty || $0.name.contains(search) }
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
    
    func batchCreatePrTrackers(_ trackers: [(String, ExerciseUnit)]) throws {
        let original = meta.prs
        let newTrackers = trackers.map { PRTracker(listId: $0.0, type: $0.1) }
        meta.prs.append(contentsOf: newTrackers)
        do {
            try StorageManager.shared.write(.workoutMeta, meta)
        } catch {
            meta.prs = original
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
    
    func deletePrTracker(_ listId: String, _ type: ExerciseUnit) throws {
        guard let original = meta.prs.first(where: { $0.listId == listId && $0.type == type}) else { return }
        let index = meta.prs.firstIndex(of: original)!
        meta.prs.remove(at: index)
        do {
            try StorageManager.shared.write(.workoutMeta, meta)
        } catch {
            meta.prs.insert(original, at: index)
            throw error
        }
    }
    
    func getPrs() -> [PRTrackerValues] {
        var prs = [PRTrackerValues]()
        for tracker in meta.prs {
            var current: (Double, Double)?
            for exercise in workouts.flatMap({ $0.exercises.flattened() }) {
                guard exercise.listId == tracker.listId, let maxValue = exercise.maxValue(for: tracker.type) else { continue }
                if current == nil || current!.0 < maxValue.0 { current = maxValue }
            }
            prs.append(
                PRTrackerValues(
                    listId: tracker.listId,
                    type: tracker.type,
                    valOne: current?.0,
                    valTwo: current?.1
                )
            )
        }
        return prs
    }
    
    // TODO: implement
    func lbToKg() throws {
//        if meta.units == .metric { return }
//        meta.units = .metric
//        do {
//            try StorageManager.shared.write(.workoutMeta, meta)
//        } catch {
//            meta.units = .imperial
//            throw error
//        }
//        workouts.forEach {
//            $0.exercises.flattened().forEach { ex in
//                if ex.unitOne == .weight {
//                    ex.sets.forEach { $0.valueOne = $0.valueOne != nil ? $0.valueOne! / 2.2 : nil }
//                }
//                if ex.unitTwo == .weight {
//                    ex.sets.forEach { $0.valueTwo = $0.valueTwo != nil ? $0.valueTwo! / 2.2 : nil }
//                }
//            }
//        }
    }
    
    // TODO: implement
    func kgToLb() throws {
//        if meta.units == .imperial { return }
//        meta.units = .imperial
//        do {
//            try StorageManager.shared.write(.workoutMeta, meta)
//        } catch {
//            meta.units = .metric
//            throw error
//        }
//        workouts.forEach {
//            $0.exercises.flattened().forEach { ex in
//                if ex.unitOne == .weight {
//                    ex.sets.forEach { $0.valueOne = $0.valueOne != nil ? $0.valueOne! * 2.2 : nil }
//                }
//                if ex.unitTwo == .weight {
//                    ex.sets.forEach { $0.valueTwo = $0.valueTwo != nil ? $0.valueTwo! * 2.2 : nil }
//                }
//            }
//        }
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
    var id: String { listId + type.rawValue }
    let listId: String
    var type: ExerciseUnit
}

struct PRTrackerValues: Codable, Hashable, Identifiable {
    var id: String { listId + type.rawValue }
    let listId: String
    var type: ExerciseUnit
    let valOne: Double?
    let valTwo: Double?
}
