//
//  ActiveWorkout.swift
//  Vincera
//
//  Created by Matt Linder on 11/4/24.
//

import SwiftUI

struct ActiveWorkoutCollapsed: View {
  @EnvironmentObject private var router: Router
  let workout: Workout
  
  var body: some View {
    VStack {
      HStack {
        Text(workout.name)
        Spacer()
        TimerView(start: workout.start)
      }
      ProgressView(value: workout.progress())
    }
    .onTapGesture { router.isShowingActiveWorkout = true }
  }
}

struct ActiveWorkoutDisplayer: ViewModifier {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var wStore: WorkoutStore
  
  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          if let workout = wStore.active, !router.isShowingActiveWorkout {
            ActiveWorkoutCollapsed(workout: workout)
          }
        }
      }
  }
}

extension View {
  var activeWorkoutDisplayer: some View {
    self.modifier(ActiveWorkoutDisplayer())
  }
}
