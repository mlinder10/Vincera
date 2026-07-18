//
//  VinceraApp.swift
//  Vincera
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

private final class BundleIdentifier {}
let bundle = Bundle(for: BundleIdentifier.self)

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

@main
struct VinceraApp: App {
    var body: some Scene {
        WindowGroup {
            Application()
        }
    }
}

struct Application: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = DataStore().initialize()
    @StateObject private var productManager = ProductManager()
    @ObservedObject private var router = Router.shared
    
    init() {
//        grantAdminStatus()
//        completeOnboarding()
        migrate_V1_to_V2()
        Task.detached(priority: .background) {
            do {
//                try VectorDatabase.shared.deleteDatabase()
                let (created, deleted) = try await VectorDatabase.shared.fillExercises()
                print("Created \(created) exercises, deleted \(deleted)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        Group {
            RootView()
                .onReceive(store.workoutTimer.publisher) { store.workoutTimer.handleCount($0) }
                .task { await requestNotificationPermission() }
                .overlay { overlayView }
                .toastDisplay(router: router)
        }
        .environmentObject(store)
        .environmentObject(productManager)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .background || newValue == .inactive {
                try? store.activeWorkout.save()
            }
        }
        .onOpenURL { url in
            Task {
                guard let token = url.absoluteString.split(separator: "://").last else { return }
                await tryGrantAdminStatus(with: String(token))
                productManager.checkAdminStatus()
            }
        }
    }
    
    private var overlayView: some View {
        Group {
            // locked
            if let subscription = productManager.currentSubscription {
                if (!router.isOnboarded && subscription == .none) || !store.surveyData.item.isValid() {
                    OnboardingFlow()
                } else if subscription == .none {
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
