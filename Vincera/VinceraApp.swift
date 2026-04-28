//
//  VinceraApp.swift
//  Vincera
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

@main
struct VinceraApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = DataStore().initialize()
    @ObservedObject private var productManager = ProductManager.shared
    @ObservedObject private var router = Router.shared
    
    init() {
//        grantAdminStatus()
//        completeOnboarding()
        migrate_V1_to_V2()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onReceive(store.workoutTimer.publisher) { store.workoutTimer.handleCount($0) }
                .task { await requestNotificationPermission() }
                .overlay { overlayView }
                .toastDisplay(router: router)
        }
        .environmentObject(store)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .background || newValue == .inactive {
                store.saveActiveWorkout()
            }
        }
    }
    
    private var overlayView: some View {
        Group {
            // locked
            if let isSubscribed = productManager.isSubscribed {
                if !router.isOnboarded && !isSubscribed {
                    OnboardingFlow()
                } else if !isSubscribed {
                    LockedView()
                }
            } else {
                Color.background.ignoresSafeArea()
            }
            
            // rating
            if router.showRatingScreen {
                RatingModal(onDismiss: { router.showRatingScreen = false })
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
