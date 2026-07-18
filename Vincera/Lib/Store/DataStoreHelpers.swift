//
//  DataStoreHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 5/6/26.
//

import Foundation

enum TransferableData: String, CaseIterable, Identifiable {
    var id: TransferableData { self }
    
    case splits, completedWorkouts, customExercises
    
    var label: String {
        switch self {
        case .splits: "Splits"
        case .completedWorkouts: "Completed Workouts"
        case .customExercises: "Custom Exercises"
        }
    }
    
    var file: File {
        switch self {
        case .splits: .splitsV2
        case .completedWorkouts: .completedWorkoutsV2
        case .customExercises: .exercisesMut
        }
    }
}

extension Array {
    mutating func merge(_ other: Self) {
        
    }
}

extension DataStore {
    
    // data management
    
    func importData(from url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw StorageError.failedToRead
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: url)
        let object = try JSONDecoder().decode([String: Data].self, from: data)
        for (key, rawData) in object {
            if rawData.isEmpty {
                print("Data empty for \(key)")
                continue
            }
            
            guard let type = TransferableData(rawValue: key) else { continue }
            
            switch type {
            case .splits:
                let importedSplits = try JSONDecoder().decode([Writers.Split].self, from: rawData)
                try? self.split.import(importedSplits)
                
            case .completedWorkouts:
                let importedCompletedWorkouts = try JSONDecoder().decode([Writers.CompletedWorkout].self, from: rawData)
                try? self.completedWorkout.import(importedCompletedWorkouts)
                
            case .customExercises:
                let importedExercises = try JSONDecoder().decode([String: ListExercise].self, from: rawData)
                ExerciseList.shared.import(importedExercises)
            }
        }
        
        self.reload()
    }
    
    func exportData(from objects: [TransferableData] = TransferableData.allCases) throws -> Data {
        var data = [String: Data]()
        
        for o in objects {
            if let decoded = try? StorageManager.readRaw(o.file) {
                data[o.rawValue] = decoded
            }
        }
        
        return try JSONEncoder().encode(data)
    }
    
    func deleteData(for objects: [TransferableData]) {
        for o in objects {
            switch o {
            case .splits: split.clear()
            case .completedWorkouts: completedWorkout.clear()
            case .customExercises: ExerciseList.shared.clear()
            }
        }
    }
    
    // split
    
    func selectSplit(_ split: Writers.Split?) throws {
        try splitMeta.update(.init(splitId: split?.id, dayIndex: 0))
    }
    
    func setDayIndex(_ newDay: Writers.Day) {
        guard let currentSplit else { return }
        guard let newIndex = currentSplit.days.firstIndex(of: newDay) else { return }
        try? splitMeta.update(.init(splitId: splitMeta.item.splitId, dayIndex: newIndex))
    }
    
    func nextDay() throws {
        guard let currentSplit, let currentDay else { return }
        guard let index = currentSplit.days.firstIndex(where: { $0.id == currentDay.id }) else { return }
        let newIndex = index == currentSplit.days.count - 1 ? 0 : index + 1
        try? splitMeta.update(.init(splitId: splitMeta.item.splitId, dayIndex: newIndex))
    }
    
    func prevDay() throws {
        guard let currentSplit, let currentDay else { return }
        guard let index = currentSplit.days.firstIndex(where: { $0.id == currentDay.id }) else { return }
        let newIndex = index == 0 ? currentSplit.days.count - 1 : index - 1
        try? splitMeta.update(.init(splitId: splitMeta.item.splitId, dayIndex: newIndex))
    }
    
    // active workout
    
    func startWorkout(workout: Builder.ActiveWorkout) throws {
        guard activeWorkout.item == nil else { throw VinceraError.existingWorkout }
        Task { try? await HealthManager.shared.startWorkout() }
        activeWorkout.item = workout
        workoutTimer = TimerData()
    }
    
    func cancelWorkout() {
        Task { try? await HealthManager.shared.cancelWorkout() }
        workoutTimer.reset()
        self.activeWorkout.item = nil
    }
    
    func endWorkout() throws {
        guard let activeWorkout = activeWorkout.item, activeWorkout.isValid() else {
            throw VinceraError.invalidWorkout
        }
        workoutTimer.reset()
        activeWorkout.endedAt = Date()
        try completedWorkout.create(activeWorkout.toCompleted())
        Task { try? await HealthManager.shared.endWorkout() }
        self.activeWorkout.item = nil
    }
    
    // completed workout
    
    func getFiltered(during date: CalendarComponents) -> [Writers.CompletedWorkout] {
        var result = [Writers.CompletedWorkout]()
        for w in self.completedWorkout.list {
            let components = w.startedAt.getComponents()
            if components.year == date.year && components.month == date.month {
                result.append(w)
            }
            if components.year < date.year ||
                (components.month < date.month &&
                 components.year == date.year) {
                break
            }
        }
        return result
    }
    
    func getVolume(during components: CalendarComponents) -> [Volume] {
        var parts = BodyPart.allCases.map { Volume(bodyPart: $0, sets: 0) }
        
        let exercises = getFiltered(during: components).flatMap({ $0.wrappers.flattened() })
        let listExercises = exercises.map({ ExerciseList.shared.getExercise($0.listId) })
        
        for e in zip(exercises, listExercises) {
            guard let listExercise = e.1 else { continue }
            guard let part = BodyPart(rawValue: listExercise.bodyPart) else { continue }
            guard let index = parts.firstIndex(where: { $0.bodyPart == part }) else { continue }
            parts[index].sets += e.0.sets.count
        }
        
        return parts
    }
    
    func getPreviousExercises(listIds: [String], workoutId: String? = nil) -> [Writers.Exercise] {
        var exercises = [Writers.Exercise]()
        
        var start = workoutId == nil ? true : false
        for w in completedWorkout.list {
            if !start && w.id == workoutId { start = true; continue }
            if !start { continue }
            for e in w.wrappers.flatMap({ $0.exercises }) {
                if !listIds.contains(e.listId) { continue }
                if exercises.contains(where: { $0.id == e.id }) { continue }
                exercises.append(e)
                if exercises.count == listIds.count { return exercises }
            }
        }
        
        return exercises
    }
    
    func getAllPreviousExercises(
        for id: String,
        since timeframe: Timeframe
    ) -> [(Writers.Exercise, Date)] {
        var result = [(Writers.Exercise, Date)]()
        
        for w in completedWorkout.list {
            if w.startedAt < timeframe.date { break }
            
            for e in w.wrappers.flattened() {
                if e.listId == id {
                    result.append((e, w.startedAt))
                }
            }
        }
        
        return result
    }
    
    // trackers
    
    func getPrs() -> [Writers.PRTrackerValues] {
        var prs = [Writers.PRTrackerValues]()
        for tracker in tracker.list {
            var current: (Double, Double)?
            for exercise in completedWorkout.list.flatMap({ $0.wrappers.flattened() }) {
                guard exercise.listId == tracker.listId, let maxValue = exercise.maxValue(for: tracker.type) else { continue }
                if current == nil || current!.0 < maxValue.0 { current = maxValue }
            }
            prs.append(
                Writers.PRTrackerValues(
                    listId: tracker.listId,
                    type: tracker.type,
                    valOne: current?.0,
                    valTwo: current?.1
                )
            )
        }
        return prs
    }
}
