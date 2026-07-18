//
//  HealthManager.swift
//  LiftLogs
//
//  Created by Matt Linder on 5/11/24.
//

import Foundation
import HealthKit

final class HealthManager {
    static let shared = HealthManager()
    
    private let healthStore = HKHealthStore()
    private var workoutBuilder: HKWorkoutBuilder? = nil
    
    private init() {}
    
    // workout
    
    func startWorkout() async throws {
        // authorization
        let typesToShare: Set = [HKWorkoutType.workoutType()]
        let typesToRead: Set<HKWorkoutType> = Set()
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        
        // core
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .indoor
        
        self.workoutBuilder = HKWorkoutBuilder(healthStore: self.healthStore, configuration: configuration, device: .local())
        try await workoutBuilder?.beginCollection(at: .now)
    }
    
    
    func endWorkout() async throws {
        guard let builder = workoutBuilder else { return }
        
        try await builder.endCollection(at: .now)
        let _ = try await builder.finishWorkout()
        
        await MainActor.run {
            self.workoutBuilder = nil
        }
    }
    
    func cancelWorkout() async throws {
        guard let builder = workoutBuilder else { return }
        
        try await builder.endCollection(at: .now)
        
        await MainActor.run {
            self.workoutBuilder = nil
        }
    }
    
    // sleep
    
    func fetchSleepData() async throws -> [SleepData] {
        // authorization
        let typesToShare: Set<HKWorkoutType> = Set()
        let typesToRead: Set = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        
        // core
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] } // should never return
        
        // Sort by end date to get the most recent samples
        let sleepDescriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 100
        )
        
        // This waits for the results properly
        let samples = try await sleepDescriptor.result(for: healthStore)
        
        return samples.compactMap { sample in
            guard let stage = HKCategoryValueSleepAnalysis(rawValue: sample.value) else { return nil }
            return SleepData(start: sample.startDate, end: sample.endDate, stage: stage)
        }
    }
}
