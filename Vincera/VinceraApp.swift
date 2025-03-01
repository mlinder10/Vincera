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
    @StateObject private var pStore = ProductStore()
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
                    .environmentObject(pStore)
                    .environmentObject(sStore)
                    .environmentObject(dStore)
                    .environmentObject(wStore)
                    .environmentObject(eStore)
                    .onReceive(wStore.timer.publisher) { wStore.timer.handleCount($0) }
                    .task(requestNotificationPermission)
            }
        }
    }
    
    private func requestNotificationPermission() async  {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var wStore: WorkoutStore
    @EnvironmentObject private var sStore: SplitStore
    @State private var showImportAlert = false
    @State private var importedSplit: Split? = nil
    
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
        .sheet(isPresented: $router.isShowingActiveWorkout, content: { sheetContent })
        .onOpenURL(perform: handleOpenURL)
        .alert("Import Split", isPresented: $showImportAlert, actions: { importAlertView}, message: { importAlertMessage })
    }
    
    private var sheetContent: some View {
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
    
    private var importAlertView: some View {
        Group {
            Button("Save") {
                if let split = importedSplit {
                    do {
                        try sStore.createSplit(split)
                        importedSplit = nil
                    } catch {
                        print("Failed to save imported split: \(error)")
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                importedSplit = nil
            }
        }
    }
    
    private var importAlertMessage: some View {
        Group {
            if let importedSplit {
                Text("Would you like to save the split '\(importedSplit.name)'?")
            } else {
                Text("Would you like to save this split?")
            }
        }
    }
    
    private func handleOpenURL(_ url: URL) {
        if let split = SplitSharingManager.shared.handleIncomingURL(url) {
            importedSplit = split
            showImportAlert = true
            router.tab = .plan
        }
    }
}
