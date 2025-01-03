//
//  VinceraApp.swift
//  Vincera
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

@main
struct VinceraApp: App {
  @StateObject private var router = Router()
  @StateObject private var sStore = SplitStore()
  @StateObject private var dStore = DayStore()
  @StateObject private var wStore = WorkoutStore()
  @StateObject private var eStore = ExerciseStore()
  
  var body: some Scene {
    WindowGroup {
      if eStore.exercises.isEmpty {
        ProgressView()
      } else {
        RootView()
          .environmentObject(router)
          .environmentObject(sStore)
          .environmentObject(dStore)
          .environmentObject(wStore)
          .environmentObject(eStore)
          .onReceive(wStore.timer.publisher) { wStore.timer.handleCount($0) }
      }
    }
  }
}

struct RootView: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var wStore: WorkoutStore
  
  var body: some View {
    TabView(selection: $router.tab) {
      
      NavigationStack(path: $router.workoutRoutes) {
        WorkoutTab()
          .rootNavigator
          .activeWorkoutDisplayer
      }
      .tabItem { Label("Workout", systemImage: "bolt") }
      .tag(Tab.workout)
      
      NavigationStack(path: $router.planRoutes) {
        PlanTab()
          .rootNavigator
          .activeWorkoutDisplayer
      }
      .rootNavigator
      .tabItem { Label("Plan", systemImage: "calendar") }
      .tag(Tab.plan)
      
      NavigationStack(path: $router.historyRoutes) {
        HistoryTab()
          .rootNavigator
          .activeWorkoutDisplayer
      }
      .tabItem { Label("History", systemImage: "clock") }
      .tag(Tab.history)
      
      NavigationStack(path: $router.exerciseRoutes) {
        ExercisesTab()
          .rootNavigator
          .activeWorkoutDisplayer
      }
      .tabItem { Label("Exercises", systemImage: "dumbbell") }
      .tag(Tab.exercises)
      
    }
    .notificationDisplayer
    .dialogDisplayer
    .detailDisplayer
    .sheet(isPresented: $router.isShowingActiveWorkout) {
      NavigationStack(path: $router.activeWorkoutRoutes) {
        if let workout = wStore.active {
          ActiveWorkoutView(workout: Binding(get: { workout }, set: { wStore.active = $0 }))
            .rootNavigator
        } else {
          Text("No active workout")
        }
      }
      .notificationDisplayer
      .dialogDisplayer
      .detailDisplayer
    }
  }
}
