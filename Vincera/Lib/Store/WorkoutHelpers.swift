//
//  WorkoutHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
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

private let file = File.workoutsV2

extension DataStore {
    
    // init
    
    func initWorkouts() {
        self.workouts = (try? StorageManager.shared.read(file)) ?? []
    }
    
    // crud
    
    func createWorkout(_ workout: Writers.Workout) throws {
        workouts.insert(workout, at: 0)
        do {
            try StorageManager.shared.write(file, workouts)
        } catch {
            workouts.removeFirst()
            throw error
        }
    }
    
    func editWorkout(_ workout: Writers.Workout) throws {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        let original = workouts[index]
        workouts[index] = workout
        do {
            try StorageManager.shared.write(file, workouts)
        } catch {
            workouts[index] = original
            throw error
        }
    }
    
    func deleteWorkout(_ workout: Writers.Workout) throws {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        workouts.remove(at: index)
        do {
            try StorageManager.shared.write(file, workouts)
        } catch {
            workouts.insert(workout, at: index)
            throw error
        }
    }
}
