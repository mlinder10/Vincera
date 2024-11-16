//
//  HealthManager.swift
//  LiftLogs
//
//  Created by Matt Linder on 5/11/24.
//

import Foundation
import HealthKit

@MainActor
final class HealthManager {
  static let shared = HealthManager()
  
  private let healthStore = HKHealthStore()
  private var workoutBuilder: HKWorkoutBuilder? = nil
  
  private init() {}
  
  private func requestAuthorization(completion: @Sendable @escaping (Bool) -> Void) {
    let typesToShare: Set = [HKWorkoutType.workoutType()]
    let typesToRead: Set<HKWorkoutType> = Set()
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
      completion(success)
    }
  }
  
  func startWorkout() {
    requestAuthorization { [weak self] success in
      guard let self = self else { return }
      guard success else {
        print("Authorization failed")
        return
      }
      
      Task { @MainActor in
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .functionalStrengthTraining
        
        self.workoutBuilder = HKWorkoutBuilder(healthStore: self.healthStore, configuration: workoutConfiguration, device: .local())
        
        guard let workoutBuilder = self.workoutBuilder else { return }
        
        do {
          try await workoutBuilder.beginCollection(at: Date())
        } catch {
          print("Error starting workout collection: \(error.localizedDescription)")
        }
      }
    }
  }

  
  func endWorkout() {
    guard let workoutBuilder = self.workoutBuilder else {
      print("No active workout session")
      return
    }
    
    workoutBuilder.endCollection(withEnd: Date()) { success, error in
      if success {
        workoutBuilder.finishWorkout { workout, error in
          if let error {
            print("Error finishing workout: \(error.localizedDescription)")
          } else {
            print("saved to apple health")
          }
        }
      } else {
        print("Error ending workout collection: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
  }
  
  func cancelWorkout() {
    guard let workoutBuilder = self.workoutBuilder else {
      print("No active workout session to cancel")
      return
    }
    
    workoutBuilder.endCollection(withEnd: Date()) { success, error in
      if !success {
        print("Error canceling workout: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
  }
}
