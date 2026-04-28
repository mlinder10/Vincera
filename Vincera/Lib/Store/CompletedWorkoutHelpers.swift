//
//  CompletedWorkoutHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

private let file = File.completedWorkoutsV2

extension DataStore {
    
    // init
    
    func initCompletedWorkouts() {
        self.completedWorkouts = (try? StorageManager.shared.read(file)) ?? []
        self.trackers = (try? StorageManager.shared.read(.trackers)) ?? []
    }
    
    // crud
    
    func createCompletedWorkout(_ workout: Writers.CompletedWorkout) throws {
        completedWorkouts.insert(workout, at: 0)
        do {
            try StorageManager.shared.write(file, completedWorkouts)
        } catch {
            completedWorkouts.removeFirst()
            throw error
        }
    }
    
    func editCompletedWorkout(_ workout: Writers.CompletedWorkout) throws {
        guard let index = completedWorkouts.firstIndex(where: { $0.id == workout.id }) else { return }
        let original = completedWorkouts[index]
        completedWorkouts[index] = workout
        do {
            try StorageManager.shared.write(file, completedWorkouts)
        } catch {
            completedWorkouts[index] = original
            throw error
        }
    }
    
    func deleteCompletedWorkout(_ workout: Writers.CompletedWorkout) throws {
        guard let index = completedWorkouts.firstIndex(where: { $0.id == workout.id }) else { return }
        completedWorkouts.remove(at: index)
        do {
            try StorageManager.shared.write(file, completedWorkouts)
        } catch {
            completedWorkouts.insert(workout, at: index)
            throw error
        }
    }
    
    func createPRTrackers(_ trackers: [(String, ExerciseUnit)]) throws {
        let original = self.trackers
        let newTrackers = trackers.map { Writers.PRTracker(listId: $0.0, type: $0.1) }
        self.trackers.append(contentsOf: newTrackers)
        do {
            try StorageManager.shared.write(.trackers, self.trackers)
        } catch {
            self.trackers = original
            throw error
        }
    }
    
    func editPrTracker(_ tracker: Writers.PRTracker) throws {
        if trackers.contains(tracker) { return }
        guard let index = trackers.firstIndex(where: { $0 == tracker }) else { return }
        let original = trackers[index]
        trackers[index] = tracker
        do {
            try StorageManager.shared.write(.trackers, trackers)
        } catch {
            trackers[index] = original
            throw error
        }
    }
    
    func deletePRTracker(_ listId: String, _ type: ExerciseUnit) throws {
        guard let original = trackers.first(where: { $0.listId == listId && $0.type == type}) else { return }
        let index = trackers.firstIndex(of: original)!
        trackers.remove(at: index)
        do {
            try StorageManager.shared.write(.trackers, trackers)
        } catch {
            trackers.insert(original, at: index)
            throw error
        }
    }
    
    // helpers
    
    func getFiltered(during date: CalendarComponents) -> [Writers.CompletedWorkout] {
        var result = [Writers.CompletedWorkout]()
        for w in self.completedWorkouts {
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
    
    func getFiltered(_ search: String, _ timeframe: Timeframe) -> [Writers.CompletedWorkout] {
        getWorkouts(timeframe: timeframe).filter { search.isEmpty || $0.name.contains(search) }
    }
    
    func getWorkouts(timeframe: Timeframe = .allTime) -> [Writers.CompletedWorkout] {
        completedWorkouts.filter({ $0.startedAt > timeframe.date })
    }
    
    func getVolume(over timeframe: Timeframe = .allTime) -> [Volume] {
        var parts = BodyPart.allCases.map { Volume(bodyPart: $0, sets: 0) }
        
        let exercises = getWorkouts(timeframe: timeframe).flatMap({ $0.wrappers.flatMap({ $0.exercises }) })
        let listExercises = exercises.map({ ExerciseList.shared.getExercise($0.listId) })
        
        for e in zip(exercises, listExercises) {
            guard let listExercise = e.1 else { continue }
            guard let part = BodyPart(rawValue: listExercise.bodyPart) else { continue }
            guard let index = parts.firstIndex(where: { $0.bodyPart == part }) else { continue }
            parts[index].sets += e.0.sets.count
        }
        
        return parts
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
        for w in completedWorkouts {
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
    
    func getPrs() -> [Writers.PRTrackerValues] {
        var prs = [Writers.PRTrackerValues]()
        for tracker in trackers {
            var current: (Double, Double)?
            for exercise in completedWorkouts.flatMap({ $0.wrappers.flattened() }) {
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
