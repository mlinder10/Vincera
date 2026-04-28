//
//  DataStore.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import Foundation

final class DataStore: ObservableObject {
    @Published var splits: [Writers.Split]
    @Published var workouts: [Writers.Workout]
    @Published var completedWorkouts: [Writers.CompletedWorkout]
    @Published var trackers: [Writers.PRTracker]
    
    @Published var activeWorkout: Builder.ActiveWorkout?
    @Published var workoutTimer: TimerData
    
    @Published var splitMeta: Writers.SplitMeta
    
    var currentSplit: Writers.Split? {
        VINCERA_SPLITS.first(where: { $0.id == splitMeta.splitId }) ??
        splits.first(where: { $0.id == splitMeta.splitId })
    }
    var currentDay: Writers.Day? {
        guard let currentSplit,
              let dayIndex = splitMeta.dayIndex,
              currentSplit.days.count > dayIndex else { return nil }
        return currentSplit.days[dayIndex]
    }
    
    init() {
        self.splits = []
        self.workouts = []
        self.completedWorkouts = []
        self.trackers = []
        
        self.activeWorkout = nil
        self.workoutTimer = TimerData()
        
        self.splitMeta = Writers.SplitMeta()
    }
    
    func initialize() -> Self {
        initSplits()
        initWorkouts()
        initCompletedWorkouts()
        initActiveWorkout()
        return self
    }
    
    func mock() -> Self {
        self.splits = MOCK_SPLITS
        self.workouts = MOCK_WORKOUTS
        self.completedWorkouts = MOCK_COMPLETED_WORKOUTS
        self.splitMeta = MOCK_SPLIT_META
        return self
    }
}
