//
//  RootView.swift
//  Vincera
//
//  Created by Matt Linder on 4/18/26.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var router = Router.shared
    @EnvironmentObject private var store: DataStore
    @State private var showImportAlert = false
    @State private var importedSplit: Split? = nil
    
    var body: some View {
        TabView(selection: $router.tab) {
            
            NavigationStack(path: $router.routes.workout) {
                WorkoutScreen()
                    .navigator
            }
            .tabItem { Label("Workout", systemImage: "bolt") }
            .tag(ProtectedTab.workout)
            
            NavigationStack(path: $router.routes.plan) {
                PlanScreen()
                    .navigator
            }
            .tabItem { Label("Plan", systemImage: "calendar") }
            .tag(ProtectedTab.plan)

            NavigationStack(path: $router.routes.history) {
                HistoryScreen()
                    .navigator
            }
            .tabItem { Label("History", systemImage: "clock") }
            .tag(ProtectedTab.history)

            NavigationStack(path: $router.routes.exercise) {
                ExerciseListScreen()
                    .navigator
            }
            .tabItem { Label("Exercises", systemImage: "dumbbell") }
            .tag(ProtectedTab.exercise)
        }
        .activeWorkoutDisplayer
        .sheet(isPresented: $router.showWorkout, content: { sheetContent })
    }
    
    private var sheetContent: some View {
        NavigationStack(path: $router.routes.activeWorkout) {
            if let workout = store.activeWorkout {
                ActiveWorkoutView(workout: workout)
                    .navigator
            } else {
                Text("No active workout")
            }
        }
    }
}

#Preview {
    RootView()
        .mockEnvironment
}
