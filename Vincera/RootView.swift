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
    
    var body: some View {
        TabView(selection: $router.tab) {
            
            NavigationStack(path: $router.routes.workout) {
                WorkoutScreen()
                    .navigator
            }
            .tabItem { Label("Workout", systemImage: "bolt") }
            .tag(ProtectedTab.workout)

            NavigationStack(path: $router.routes.history) {
                HistoryScreen()
                    .navigator
            }
            .tabItem { Label("History", systemImage: "clock") }
            .tag(ProtectedTab.history)
            
            NavigationStack(path: $router.routes.library) {
                ExerciseListScreen()
                    .navigator
            }
            .tabItem { Label("Exercises", systemImage: "dumbbell.fill") }
            .tag(ProtectedTab.library)
            
            NavigationStack(path: $router.routes.settings) {
                SettingsScreen()
                    .navigator
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(ProtectedTab.settings)
        }
        .activeWorkoutDisplayer
        .sheet(isPresented: $router.showWorkout, content: { sheetContent })
    }
    
    @ViewBuilder
    private var sheetContent: some View {
        NavigationStack(path: $router.routes.activeWorkout) {
            if let workout = store.activeWorkout.item {
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
