//
//  ActiveWorkoutHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 3/28/26.
//

import Foundation

extension DataStore {
    
    // init
    
    func initActiveWorkout() {
        let workout: Writers.ActiveWorkout? = try? StorageManager.shared.read(.activeWorkout)
        self.activeWorkout = workout?.toBuilder()
    }
    
    // crud
    
    func saveActiveWorkout() {
        let workout = activeWorkout?.toWriter()
        try? StorageManager.shared.write(.activeWorkout, workout)
    }
    
    // helpers
    
    func startWorkout(workout: Builder.ActiveWorkout) throws {
        guard activeWorkout == nil else { throw VinceraError.existingWorkout }
        Task { HealthManager.shared.startWorkout() }
        activeWorkout = workout
        workoutTimer = TimerData()
    }
    
    func cancelWorkout() {
        workoutTimer.reset()
        self.activeWorkout = nil
    }
    
    func endWorkout() throws {
        guard let activeWorkout, activeWorkout.isValid() else {
            throw VinceraError.invalidWorkout
        }
        workoutTimer.reset()
        activeWorkout.endedAt = Date()
        try createCompletedWorkout(activeWorkout.toCompleted())
        Task { HealthManager.shared.endWorkout() }
        self.activeWorkout = nil
    }
}
